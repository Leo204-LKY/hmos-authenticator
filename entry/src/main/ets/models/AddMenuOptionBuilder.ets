import { scanBarcode, scanCore } from '@kit.ScanKit';
import { addAuthenticatorFromUrl } from '../utils/AddAuthenticatorItemFromUrl';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { EventConstants } from './EventConstants';

let context: Context | undefined;

export function buildAddMenuOptions(context_: Context, navPathStack: NavPathStack): Array<MenuElement> {
  context = context_
  return [
    {
      value: $r("app.string.addMenuOptions_scanToAdd"),
      icon: $r('app.media.ic_public_scan'),
      action: scanToAdd
    },
    {
      value: $r("app.string.addMenuOptions_manualAdd"),
      icon: $r('app.media.ic_public_edit'),
      action: () => { navPathStack.pushPath({ name: 'EditPage' }) }
    }
  ]
}

let scanToAdd = () => {
  let options: scanBarcode.ScanOptions = {
    scanTypes: [scanCore.ScanType.QR_CODE],
    enableMultiMode: true,
    enableAlbum: true
  };

  try {
    scanBarcode.startScanForResult(context, options)
      .then((result: scanBarcode.ScanResult) => {
        let scanValue = result.originalValue
        console.log(`Scan result: ${scanValue}`)
        if (scanValue.toLowerCase().startsWith('otpauth://totp/')) {
          addAuthenticatorFromUrl(scanValue)
            .then(() => {
              context?.eventHub.emit(EventConstants.ON_UPDATE_AUTHENTICATORS)
              promptAction.showToast({
                message: $r('app.string.scanAdd_successToast'),
                duration: 2000
              })
            })
        } else if (scanValue.toLowerCase().startsWith('otpauth://hotp/')) { // TOTP 类型暂不支持
          promptAction.showToast({
            message: $r('app.string.scanAdd_notSupportToast'),
            duration: 3000
          })
        } else {  // 非有效的 OTP 二维码
          promptAction.showToast({
            message: $r('app.string.scanAdd_invalidCodeToast'),
            duration: 2000
          })
        }
      })
      .catch((error: BusinessError) => {
        console.log(`Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`)
      })
  } catch (error) {
    console.error(`Failed to start the scanning service. Code:${error.code}, message: ${error.message}`)
  }
}