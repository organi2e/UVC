# UVC
This framework provides an interface of UVC for the compatible camera with AVFoundation.  
i.e. 
```
let aDevice: AVCaptureDevice  
let uvc: UVC = try UVC(device: aDevice)  
  
uvc.autoFocus = false  
uvc.focus = 0.9  
```
