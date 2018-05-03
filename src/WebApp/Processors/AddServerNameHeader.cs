using System;
using Sitecore.Pipelines.HttpRequest;

namespace WebApp.Processors
{
    public class AddServerNameHeader : HttpRequestProcessor
    {
        public override void Process(HttpRequestArgs args)
        {
            args.HttpContext.Response.Headers["X-Machine-Name"] = Environment.MachineName.ToLowerInvariant();
        }
    }
}