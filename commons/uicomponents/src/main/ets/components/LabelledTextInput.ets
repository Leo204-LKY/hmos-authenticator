@Component
export struct LabelledTextInput {
  @Link text: string;
  @State label: ResourceStr = 'Label';
  @State inputType: InputType = InputType.Normal;
  @State inputEnabled: boolean = true;
  @State maxInputLength: number | null = null;
  @State enterKeyType: EnterKeyType = EnterKeyType.Done;
  @State placeholder: string | null = null;
  @State required: boolean = false;
  @State errorMessage: ResourceStr = $r("app.string.LabelledTextInput_defaultErrorMessage");
  onChange: () => void = () => {};
  private _currentError: ResourceStr | undefined = undefined; // 首次留空不报错

  build() {
    Column({ space: 5 }) {
      Text(this.label)
        .offset({ left: 16, right: 16 })
      TextInput({ placeholder: this.placeholder, text: $$this.text })
        .width('100%')
        .type(this.inputType)
        .enabled(this.inputEnabled)
        .maxLength(this.maxInputLength)
        .enterKeyType(this.enterKeyType)
        .showError(this._currentError)
        .onChange(() => {
          this.onChange();
          if (this.text.length === 0 && this.required) {
            this._currentError = this.errorMessage;
          } else {
            this._currentError = undefined;
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}