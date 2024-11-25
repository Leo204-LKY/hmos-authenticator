@Preview
@CustomDialog
export struct CancelAddDialog {
  dialogController?: CustomDialogController;
  confirm: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Text($r('app.string.CancelAddDialog_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text($r('app.string.CancelAddDialog_description'))
        .textAlign(TextAlign.Center)

      Row() {
        Button($r('app.string.CancelAddDialog_noButton'))
          .width('100%')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .flexShrink(1)
          .fontWeight(FontWeight.Bold)
          .onClick(() => { this.dialogController?.close(); })

        Divider()
          .height(24)
          .strokeWidth(2)
          .vertical(true)
          .color($r('sys.color.comp_background_tertiary'))
          .margin({ left: 8, right: 8 })

        Button($r('app.string.CancelAddDialog_yesButton'))
          .width('100%')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .flexShrink(1)
          .fontColor($r('sys.color.warning'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.dialogController?.close();
            this.confirm();
          })
      }
      .width('100%')
    }
    .padding(20)
  }
}