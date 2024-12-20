@Preview
@CustomDialog
export struct ConfirmRemoveDialog {
  dialogController?: CustomDialogController;
  confirm: () => void = () => {};
  authenticatorName: string = '';
  private verificationCode: number = -1;
  private readonly MIN_CODE_RANGE: number = 1000;  // 生成验证码的最小数字
  private readonly MAX_CODE_RANGE: number = 9999;  // 生成验证码的最大数字
  private readonly MAX_ATTEMPTS: number = 100;     // 尝试生成验证码的次数
  private countdownTime: number = 10;
  private countdownIntervalId: number | undefined;
  @State removeEnabled: boolean = false;
  @State removeButtonText: string = `${getContext(this).resourceManager.getStringSync($r('app.string.ConfirmRemoveDialog_removeButton'))}(${this.countdownTime})`;
  @State inputCode: string = '';

  build() {
    Column({ space: 16 }) {
      Text($r('app.string.ConfirmRemoveDialog_title', this.authenticatorName))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text($r('app.string.ConfirmRemoveDialog_description'))
        .textAlign(TextAlign.Center)

      Column({ space: 12 }) {
        Text() {
          // 拆分 Text 以实现验证码加粗
          Span($r('app.string.ConfirmRemoveDialog_verificationCodeDescription_1'))
          Span(this.verificationCode.toString())
            .fontWeight(FontWeight.Bold)
          Span($r('app.string.ConfirmRemoveDialog_verificationCodeDescription_2'))
        }
        .width('100%')
        .textAlign(TextAlign.Center)
        TextInput({ text: this.inputCode, placeholder: $r('app.string.ConfirmRemoveDialog_codeInputPlaceholder') })
          .type(InputType.Number)
          .copyOption(CopyOptions.None)
          .onChange((value: string) => {
            this.inputCode = value;
            this.checkIfAllowRemove();
          })
      }

      Row() {
        Button($r('app.string.ConfirmRemoveDialog_cancelButton'))
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

        Button(this.removeButtonText)
          .width('100%')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .flexShrink(1)
          .fontColor($r('app.color.warning'))
          .fontWeight(FontWeight.Bold)
          .enabled(this.removeEnabled)
          .onClick(() => {
            this.dialogController?.close();
            this.confirm();
          })
      }
      .width('100%')
    }
    .padding(20)
  }

  aboutToAppear(): void {
    // 验证码生成：不允许有三位及以上连续的相同数字
    let code: number = Math.floor(Math.random() * (this.MAX_CODE_RANGE - this.MIN_CODE_RANGE + 1)) + this.MIN_CODE_RANGE;
    let attemps: number = 0;
    while (attemps < this.MAX_ATTEMPTS) {
      const codeStr = code.toString();
      let isValidCode = true;
      for (let j = 0; j < codeStr.length - 2; j++) {
        if (codeStr[j] === codeStr[j + 1] && codeStr[j] === codeStr[j + 2]) {
          isValidCode = false;
          break;
        }
      }
      if (isValidCode) break;
      code = Math.floor(Math.random() * (this.MAX_CODE_RANGE - this.MIN_CODE_RANGE + 1)) + this.MIN_CODE_RANGE;
      attemps++;
    }
    this.verificationCode = code;

    this.countdownTime = 10;
    this.countdownIntervalId = setInterval(() => { this.countdown(); }, 1000);
  }

  aboutToDisappear(): void {
    this.stopCountdown();
  }

  private countdown() {
    this.countdownTime--;
    if (this.countdownTime === 0) {
      this.checkIfAllowRemove();
      this.removeButtonText = getContext(this).resourceManager.getStringSync($r('app.string.ConfirmRemoveDialog_removeButton'))
      this.stopCountdown()
    } else {
      this.removeEnabled = false;
      this.removeButtonText = `${getContext(this).resourceManager.getStringSync($r('app.string.ConfirmRemoveDialog_removeButton'))}(${this.countdownTime})`
    }
  }

  private stopCountdown() {
    if (this.countdownIntervalId != undefined) {
      clearInterval(this.countdownIntervalId);
      this.countdownIntervalId = undefined;
    }
  }

  private checkIfAllowRemove() {
    if (this.countdownTime <= 0 && this.verificationCode === Number(this.inputCode)) {
      this.removeEnabled = true;
    } else {
      this.removeEnabled = false;
    }
  }
}