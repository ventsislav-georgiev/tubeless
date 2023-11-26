using System;
using System.Text.Json;
using Avalonia.Platform;
using TubeLess.Models;

namespace TubeLess.Services;

public class AssetsService
{
  public static AppConfiguration AppConfig => JsonSerializer.Deserialize<AppConfiguration>(AssetLoader.Open(new Uri("avares://TubeLess/Assets/appsettings.json")))!;
}
