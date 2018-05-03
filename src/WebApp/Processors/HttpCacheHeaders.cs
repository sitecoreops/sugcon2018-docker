using System;
using System.Web;
using Sitecore.Mvc.Pipelines.Request.RequestEnd;

namespace WebApp.Processors
{
    public class HttpCacheHeaders : RequestEndProcessor
    {
        public override void Process(RequestEndArgs args)
        {
            var pageContext = args.PageContext;

            if (pageContext?.RequestContext.HttpContext.Response.StatusCode != 200)
            {
                return;
            }

            var requestContext = pageContext.RequestContext.HttpContext;

            requestContext.Response.Cache.SetCacheability(HttpCacheability.Public);
            requestContext.Response.Cache.SetMaxAge(TimeSpan.FromMinutes(1));
        }
    }
}