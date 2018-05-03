using System.Web.Mvc;
using Sitecore.Mvc.Presentation;

namespace WebApp.Controllers
{
    public class ArticleController : Controller
    {
        public ActionResult Index()
        {
            var model = RenderingContext.Current.Rendering.Item;

            return View(model);
        }
    }
}