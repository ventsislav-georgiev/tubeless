using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Google.Apis.YouTube.v3.Data;
using TubeLess.Services;

namespace TubeLess.Models;

public class Video
{
  public SearchResult SearchResult { get; init; }
  public string Author => SearchResult.Snippet.ChannelTitle;
  public string Title => SearchResult.Snippet.Title;
  public string CoverUrl => SearchResult.Snippet?.Thumbnails?.High?.Url ?? "";

  public Video(SearchResult searchResult)
  {
    SearchResult = searchResult;
  }

  public static async Task<IEnumerable<Video>> SearchAsync(string searchTerm)
  {
    var part = "snippet";
    var maxResults = 50;
    var apiKey = AssetsService.AppConfig.ApiKey;

    Debug.WriteLine($"Searching for {searchTerm}...");
    var resp = await HttpService.Instance.GetAsync($"https://content-youtube.googleapis.com/youtube/v3/search?part={part}&maxResults={maxResults}&q={searchTerm}&key={apiKey}&type=video");
    Debug.WriteLine($"Got response: {resp.StatusCode}");

    if (!resp.IsSuccessStatusCode)
    {
      return Array.Empty<Video>();
    }

    var searchListResponse = JsonSerializer.Deserialize<SearchListResponse>(
      resp.Content.ReadAsStream(),
      options: new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

    if (searchListResponse == null)
    {
      Debug.WriteLine($"Got null response");
      return Array.Empty<Video>();
    }

    Debug.WriteLine($"Got {searchListResponse.Items.Count} items");
    return searchListResponse.Items.Select(x => new Video(x));
  }

  public async Task<Stream> LoadCoverBitmapAsync()
  {
    Debug.WriteLine($"Loading cover bitmap for {Title}...");
    Debug.WriteLine($"{JsonSerializer.Serialize(SearchResult)}");

    var resp = await HttpService.Instance.GetAsync(CoverUrl); // TODO: CORS violation in browser
    return await resp.Content.ReadAsStreamAsync();
  }

  public static async Task<Video> LoadFromStream(Stream stream)
  {
    return (await JsonSerializer.DeserializeAsync<Video>(stream).ConfigureAwait(false))!;
  }
}
