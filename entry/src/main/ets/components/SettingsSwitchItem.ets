@Component
export struct SettingsSwitchItem {
  @State title: ResourceStr = 'SettingsSwitchItem';
  @State description: ResourceStr = '';
  @Link isOn: boolean;
  onChange: Function = (isOn: boolean) => {this.isOn = isOn};

  build() {
    ListItem() {
      Row() {
        Column() {
          Text(this.title)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(this.description)
            .width('100%')
            .fontColor($r('app.color.text_secondary'))
            .fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .onChange((isOn: boolean) => { this.onChange(isOn); })
      }
    }
    .padding({ top: 16, bottom: 16 })
  }
}