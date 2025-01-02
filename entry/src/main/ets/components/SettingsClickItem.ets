@Component
export struct SettingsClickItem {
  @Require @Prop title: ResourceStr;
  @Prop description: ResourceStr | undefined;
  onItemClick = (_: ClickEvent) => {};

  @Styles
  onPress() {
    .backgroundColor($r('app.color.background_pressed'))
  }

  @Styles
  onNormal() {
    .backgroundColor(null)
  }

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

        Image($r('app.media.ic_public_arrow_right'))
          .height(24)
          .width(24)
          .fillColor($r('app.color.text_secondary'))
          .margin({ left: 8, right: -8 })
      }
    }
    .constraintSize({ minHeight: 42 })
    .padding({ left: 12, right: 12 })
    .margin({ left: -12, right: -12, top: 4, bottom: 4 })
    .borderRadius(12)
    .onClick(this.onItemClick)
    .stateStyles({
      normal: this.onNormal,
      pressed: this.onPress
    })
  }
}