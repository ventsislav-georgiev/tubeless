using System.Net.Http;

namespace TubeLess.Services;

public class HttpService
{
  public static HttpClient Instance => new()
  {
    DefaultRequestHeaders = {
        { "Accept", "application/json" },
      },
  };
}
