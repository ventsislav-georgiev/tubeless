using System.Diagnostics;
using System.Threading.Tasks;
using Avalonia.Media.Imaging;
using ReactiveUI;
using TubeLess.Models;

namespace TubeLess.ViewModels;

public class VideoViewModel : ViewModelBase
{
    private readonly Video _video;

    public string Author => _video.Author;

    public string Title => _video.Title;

    private Bitmap? _cover;

    public Bitmap? Cover
    {
        get => _cover;
        private set => this.RaiseAndSetIfChanged(ref _cover, value);
    }

    public VideoViewModel(Video video)
    {
        _video = video;
    }

    public static async Task<VideoViewModel> FromVideo(Video video)
    {
        var viewModel = new VideoViewModel(video);
        await using (var imageStream = await video.LoadCoverBitmapAsync())
        {
            viewModel.Cover = await Task.Run(() => Bitmap.DecodeToWidth(imageStream, 480));
        }

        return viewModel;
    }
}
