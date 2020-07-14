package main

import (
    . "github.com/logrusorgru/aurora"
    "github.com/go-resty/resty"
    "fmt"
    "log"
    "crypto/md5"
    "encoding/hex"
    "encoding/base64"
)

type MSIResult struct {
    AccessToken  string `json:"access_token"`
    Resource     string `json:"resource"`
}

type SignResult struct {
    Kid   string `json:"kid"`
    Value string `json:"value"`
}

func HashMd5Base64Urlenc(text string) string {
    hasher := md5.New()
    hasher.Write([]byte(text))
    hash := hex.EncodeToString(hasher.Sum(nil))

    return base64.RawURLEncoding.EncodeToString([]byte(hash))
}

func main() {
    // resty.SetDebug(true)
    // Get Access Token
    msiUrl := "http://169.254.169.254/metadata/identity/oauth2/token"
    msiResp, err := resty.R().
          SetQueryParams(map[string]string{
              "resource": "https://vault.azure.net",
              "api-version": "2018-02-01",
          }).
          SetHeader("Accept", "application/json").
          SetHeader("Metadata", "true").
          SetResult(&MSIResult{}).
          Get(msiUrl)

    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("\nGot Access Token from Managed Service Identity:\n")
    accessToken := fmt.Sprintf("%#s", msiResp.Result().(*MSIResult).AccessToken)
    fmt.Println(Red(accessToken))


    // Sign message
    signUrl := "https://alice.vault.azure.net/keys/p256-in-hsm/sign"
    signResp, err := resty.R().
          SetQueryParams(map[string]string{
              "api-version": "2016-10-01",
          }).
          SetHeader("Content-Type", "application/json").
          SetHeader("Accept", "application/json").
          SetAuthToken(accessToken).
          SetBody(fmt.Sprintf(`
            {
              "alg": "ES256",
              "value": "%s"
            }`, HashMd5Base64Urlenc("Where does Tiger King store its secrets?"))).
          SetResult(&SignResult{}).
          Post(signUrl)

    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(Green("\nSign result:"))
    signResultKid := fmt.Sprintf("\n    Kid: %#s", signResp.Result().(*SignResult).Kid)
    signResultValue := fmt.Sprintf("\n    Value: %#s", signResp.Result().(*SignResult).Value)
    fmt.Println(signResultKid, signResultValue, "\n")
}
apibuntu ~/keyvault-go