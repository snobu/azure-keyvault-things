using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Azure.Identity;
using Microsoft.Azure.KeyVault;
using Azure.Security.KeyVault.Secrets;
using Azure.Security.KeyVault.Certificates;
using Microsoft.Azure.Services.AppAuthentication;
using System.Net.Http;
using System.Security.Cryptography.X509Certificates;

namespace KeyVaultAspNet47.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public async Task<ActionResult> Secrets()
        {

            // Via App Service reference
            // See https://docs.microsoft.com/bs-cyrl-ba/azure/app-service/app-service-key-vault-references
            // For example:
            //     @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/mysecret/ec96f02080254f109c51a1f14cdb1931)
            //     or
            //     @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/mysecret/)
            //     if you only care about the latest version of that secret
            ViewBag.ViaRef = ConfigurationManager.AppSettings["secret1"];

            // Via Key Vault SDK
            string keyVaultInstance = "https://alice.vault.azure.net";
            SecretClient secretClient = new SecretClient(new Uri(keyVaultInstance), new DefaultAzureCredential());
            KeyVaultSecret secret = await secretClient.GetSecretAsync("from-NET-SDK");
            ViewBag.ViaSDK = secret.Value;

            // Via configBuilder (see web.config)
            ViewBag.ViaBuilder = ConfigurationManager.AppSettings["secret2"];

            // Manual REST API calls
            AzureServiceTokenProvider tokenProvider = new AzureServiceTokenProvider();
            // Resource URI for Key Vault is always https://vault.azure.net,
            // irrespective of the name of your Key Vault
            string accessToken = await tokenProvider.GetAccessTokenAsync("https://vault.azure.net");
            HttpClient httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {accessToken}");
            // Response is a JSON object, the secret value is returned as response["value"] and looks like this -
            //  {
            //      "value": "TH3 VALU3 0F THE S3CRE7",
            //      "contentType": "this_property_is/completely_arbitrary",
            //      "id": "https://<YOUR-VAULT-NAME>.vault.azure.net/secrets/<NAME-OF-YOUR-SECRET>/d96492d7b6d744a085a37c812badb3e4",
            //      "attributes": {
            //          "enabled": true,
            //          "created": 1526314127,
            //          "updated": 1526314127,
            //          "recoveryLevel": "Purgeable"
            //      }
            //  }
            string secretOverRest = await httpClient.GetStringAsync("https://alice.vault.azure.net/secrets/secret1?api-version=7.0");
            ViewBag.ViaRest = secretOverRest;


            // Get certificate from Key Vault
            CertificateClient certClient = new CertificateClient(new Uri(keyVaultInstance), new DefaultAzureCredential());
            KeyVaultCertificate cert = await certClient.GetCertificateAsync("rsa-cert-pem");
            X509Certificate2 x509cert = new X509Certificate2(cert.Cer);
            ViewBag.CertSubject = x509cert.Subject;
            ViewBag.CertId = cert.Id;
            ViewBag.CertName = cert.Name;

            return View();
        }
    }
}