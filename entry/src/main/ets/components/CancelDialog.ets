@Preview
@CustomDialog
export struct CancelDialog {
  @Require @Prop message: ResourceStr;
  dialogController?: CustomDialogController;
  confirm: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Text($r('app.string.CancelDialog_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text(this.message)
        .textAlign(TextAlign.Center)

      Row() {
        Button($r('app.string.CancelDialog_noButton'))
          .width('100%')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .flexShrink(1)
          .fontWeight(FontWeight.Bold)
          .onClick(() => { this.dialogController?.close(); })

        Divider()
          .height(24)
          .strokeWidth(2)
          .vertical(true)
          .color($r('app.color.divider'))
          .margin({ left: 8, right: 8 })

        Button($r('app.string.CancelDialog_yesButton'))
          .width('100%')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .flexShrink(1)
          .fontColor($r('app.color.warning'))
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