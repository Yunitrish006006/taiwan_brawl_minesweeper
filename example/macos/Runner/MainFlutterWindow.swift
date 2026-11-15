import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    super.awakeFromNib()
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    windowFrame.size = NSSize(width: 390, height: 844)
    if let screen = NSScreen.main {
      windowFrame.origin.x = screen.visibleFrame.midX - windowFrame.size.width / 2
      windowFrame.origin.y = screen.visibleFrame.midY - windowFrame.size.height / 2
    }
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
  }
}
