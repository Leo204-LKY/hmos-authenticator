@Component
export struct SettingsSelectItem {
  @Require @Prop title: ResourceStr;
  @Prop description: ResourceStr = '';
  @Require @Prop optionsText: ResourceStr[];
  @Link selectedIndex: number;
  @Prop value: ResourceStr;
  onSelect = (_: number) => {}

  private selectOption = this.optionsText.map(text => {
    return { value: text } as SelectOption
  })

  build() {
    ListItem() {
      Row() {
        Column() {
          Text(this.title)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(this.description)
            .width('100%')
            .fontColor($r('app.color.text_secondary'))
            .fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Select(this.selectOption)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.background_secondary'))
          .menuAlign(MenuAlignType.END)
          .borderRadius(12)
          .selected(this.selectedIndex)
          .value(this.value)
          .onSelect((index: number, value?: string) => {
            this.selectedIndex = index;
            if (value) {
              this.value = value;
            }
            this.onSelect(index);
          })
          .margin({ right: -8 })
      }
      .width('100%')
      .margin({ top: 8, bottom: 8 })
    }
  }
}