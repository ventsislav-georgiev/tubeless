using Avalonia.ReactiveUI;
using TubeLess.ViewModels;

namespace TubeLess.Views;

public partial class MainWindow : ReactiveWindow<MainViewModel>
{
    public MainWindow()
    {
        InitializeComponent();
    }
}
