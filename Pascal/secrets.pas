program secrets;
{$H+}
{$MODE OBJFPC}

uses Classes, SysUtils, fphttpclient, fpjson, jsonparser;

var
  MIResponse, Secret, Response, AccessToken : AnsiString;
  jData : TJSONData;
  jObject : TJSONObject;
begin
  With TFPHttpClient.Create(Nil) do
    try
      {* Get Key Vault access token via Managed Identity *}
      AddHeader('User-Agent', 'fphttpclient/Turbo Pascal');
      AddHeader('Metadata', 'true');
      Response := Get('http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net');

      WriteLn('HTTP Response Status Code from Managed Identity: ', ResponseStatusCode);
      Free;

    except
      on E: Exception do
        WriteLn('An exception was raised: ', E.Message);
    end;
  {* WriteLn(Response); *}
  jData := GetJSON(Response);
  jObject := TJSONObject(jData);
  AccessToken := jObject.Get('access_token');
  MIResponse := jData.FormatJSON;
  WriteLn(MIResponse);

  With TFPHttpClient.Create(Nil) do
    try
      {* Get Key Vault secret *}
      AddHeader('User-Agent', 'fphttpclient/Turbo Pascal');
      AddHeader('Authorization', 'Bearer ' + AccessToken);
      Response := Get('https://alice.vault.azure.net/secrets/secret1?api-version=7.0');

      WriteLn('HTTP Response Status Code from Key Vault: ', ResponseStatusCode);
      Free;

    except
      on E: Exception do
        WriteLn('An exception was raised: ' + E.Message);
    end;
  {* WriteLn(Response) *};
  jData := GetJSON(Response);
  jObject := TJSONObject(jData);
  Secret := jData.FormatJSON;
  WriteLn(Secret);