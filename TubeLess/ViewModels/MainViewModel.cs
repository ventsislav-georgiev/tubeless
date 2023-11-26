using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Reactive.Concurrency;
using System.Threading;
using System.Threading.Tasks;
using ReactiveUI;
using TubeLess.Models;

namespace TubeLess.ViewModels;

public class MainViewModel : ViewModelBase
{
    public ObservableCollection<VideoViewModel> Videos { get; } = [];

    public MainViewModel()
    {
        RxApp.MainThreadScheduler.ScheduleAsync(LoadVideos);
    }

    public async Task LoadVideos(IScheduler scheduler, CancellationToken token)
    {
        Debug.WriteLine($"Loading videos...");
        var videos = await Video.SearchAsync("dotnet");
        if (videos == null)
        {
            Debug.WriteLine($"Got null response");
            return;
        }

        Debug.WriteLine($"Loaded videos");

        try {
            foreach (var video in videos)
            {
                if (video == null)
                {
                    Debug.WriteLine($"Got null video");
                    continue;
                }

                var viewModel = await VideoViewModel.FromVideo(video);
                Videos.Add(viewModel);

                if (token.IsCancellationRequested)
                {
                    return;
                }
            }
        } catch (Exception e) {
            Debug.WriteLine($"Exception: {e}");
        }
    }
}
