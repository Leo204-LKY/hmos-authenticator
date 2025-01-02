@Component
export struct SettingsSwitchItem {
  @Require @Prop title: ResourceStr;
  @Prop description: ResourceStr | undefined;
  @Link isOn: boolean;
  onChange: Function = (isOn: boolean) => {this.isOn = isOn};

  build() {
    ListItem() {
      Row() {
        Column() {
          Text(this.title)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .fontColor($r('app.color.text_primary'))
          Text(this.description)
            .width('100%')
            .fontColor($r('app.color.text_secondary'))
            .fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .onChange((isOn: boolean) => { this.onChange(isOn); })
          .margin({ left: 8 })
      }
    }
    .constraintSize({ minHeight: 60 })
    .padding({ top: 8, bottom: 8 })
  }
}