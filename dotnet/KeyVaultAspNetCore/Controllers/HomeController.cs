using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using KeyVaultAspNetCore.Models;
using Microsoft.Extensions.Configuration;

namespace KeyVaultAspNetCore.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;


        private IConfiguration _configuration;

        public HomeController(ILogger<HomeController> logger, IConfiguration Configuration)
        {
            _logger = logger;
            _configuration = Configuration;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Secrets()
        {
            // When running locally secret value is read from dotnet Secret Manager,
            // when on Azure secret is fetched from Key Vault via DI.
            // Secret name in Key Vault: 'secret1'
            ViewBag.secret1 = _configuration["secret1"];

            // Hierarchical keys:
            // https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-3.1#configuration-keys-and-values
            // Secret name in Key Vault: 'GitHub--ApiKey'
            ViewBag.ApiKey1 = _configuration["GitHub:ApiKey"];

            // Secret name in Key Vault: 'GitHub--ApiKey'
            ViewBag.ApiKey2 = _configuration.GetSection("GitHub")["ApiKey"];

            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
