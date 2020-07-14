package com.azure.keyvault.sample.azurekeyvaultsample;

import org.apache.http.ssl.SSLContexts;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.apache.commons.codec.Charsets;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.security.KeyFactory;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.PublicKey;
import javax.net.ssl.SSLContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.security.keyvault.certificates.CertificateClient;
import com.azure.security.keyvault.certificates.CertificateClientBuilder;
import com.azure.security.keyvault.certificates.models.KeyVaultCertificateWithPolicy;
import com.azure.security.keyvault.secrets.SecretClient;
import com.azure.security.keyvault.secrets.SecretClientBuilder;
import com.azure.security.keyvault.secrets.models.KeyVaultSecret;
import com.nimbusds.jose.util.IOUtils;

@SpringBootApplication
public class AzureKeyvaultSampleApplication {

	public static void main(String[] args) throws CertificateException {
		SpringApplication.run(AzureKeyvaultSampleApplication.class, args);

		// IMPORTANT!
		// java-dotnev WON'T WORK with DefaultAzureCredetialBuilder
		// as the JVM can't inject env vars into a running process
		// https://github.com/cdimascio/java-dotenv

		// See this for clarity on DefaultAzureCredential:
		// https://github.com/Azure/azure-sdk-for-java/tree/master/sdk/identity/azure-identity#credentials
		// In short: When developing locally it expects a service principal as env vars.
		// When running in Azure in a serivce that has Managed Identity enabled
		// it will acquire a token via that mechanism (you don't need to provide any
		// secrets)
		DefaultAzureCredential credential = new DefaultAzureCredentialBuilder().build();

		SecretClient secretClient = new SecretClientBuilder().vaultUrl("https://alice.vault.azure.net")
				.credential(credential).buildClient();

		CertificateClient certClient = new CertificateClientBuilder().vaultUrl("https://alice.vault.azure.net")
				.credential(credential).buildClient();

		KeyVaultCertificateWithPolicy certificate = certClient.getCertificate("Joes-Crab-Shack-PKCS8");
		byte[] publicKey = certificate.getCer();
		//System.out.println("Public Key:");
		//System.out.println(new String(publicKey));

		KeyVaultSecret secret = secretClient.getSecret(certificate.getName(), certificate.getProperties().getVersion());
		String privateKey = secret.getValue();
		String truncatedPrivateKey = privateKey.substring(0, Math.min(privateKey.length(), 30));

		System.out.printf("\nSecret is returned:\n    Name: %s\n    Value: %s\n\n",
			secret.getName(),
			truncatedPrivateKey + "[..truncated..]");

		System.out.printf("Recevied certificate:\n    Name: %s\n    Version: %s\n    Secret ID:%s\n",
				certificate.getProperties().getName(),
				certificate.getProperties().getVersion(),
				certificate.getSecretId());

		CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
		InputStream in = new ByteArrayInputStream(certificate.getCer());
		X509Certificate cert = (X509Certificate)certFactory.generateCertificate(in);
		System.out.printf("    Subject: %s\n", cert.getSubjectDN());

		// doClientCertAuth() doesn't work. I've opened a Stack Overflow thread
		// asking how to approach the problem at https://stackoverflow.com/q/62701407/4148708.
		// If you know how to rewrite doClientCertAuth() to do the right thing, please
		// don't be modest, send in a pull request.
		System.out.println("Calling endpoint with client certificate...");
		String res = doClientCertAuth(publicKey, privateKey);
		System.out.println(res);
	}

	public static String doClientCertAuth(byte[] publicKey, String privateKey) {
		String body = "";
		CloseableHttpResponse response = null;

		try {
			// Private
			byte[] decodedPrivateKey = Base64.getDecoder().decode(privateKey.getBytes());
			PKCS8EncodedKeySpec specPrivate = new PKCS8EncodedKeySpec(decodedPrivateKey);
    		KeyFactory kfPrivate = KeyFactory.getInstance("RSA");
			PrivateKey privateKeySpec = kfPrivate.generatePrivate(specPrivate);

			// Public
			X509EncodedKeySpec specPublic = new X509EncodedKeySpec(publicKey);
			KeyFactory kfPublic = KeyFactory.getInstance("RSA");
			PublicKey publicKeySpec = kfPublic.generatePublic(specPublic);

			CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
			InputStream in = new ByteArrayInputStream(publicKey);
			X509Certificate certificate = (X509Certificate)certFactory.generateCertificate(in);
			
			KeyStore keyStore = KeyStore.getInstance("PKCS12");
			System.out.println(KeyStore.getDefaultType());
			keyStore.load(null, null);
			Certificate[] certChain = new Certificate[1];  
			certChain[0] = certificate;
			// This results in
			//   java.security.InvalidKeyException: IOException : version mismatch:
			//   (supported:     00, parsed:     03)
			// even though the private key seems to be of type PKCS#8
			keyStore.setKeyEntry("key1", privateKeySpec.getEncoded(), certChain);

			SSLContext sslContext = SSLContexts.custom().loadKeyMaterial(keyStore, null).build();

			CloseableHttpClient httpClient = HttpClients.custom().setSSLContext(sslContext).build();
			response = httpClient.execute(new HttpGet("https://remote.that.requires.client.certificate/"));

			InputStream inputStream = response.getEntity().getContent();

			body = IOUtils.readInputStreamToString(inputStream, Charsets.UTF_8);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return body;
	}

}
