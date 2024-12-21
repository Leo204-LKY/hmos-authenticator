@Preview
@Component
export struct ListItemGroupHeader {
  @Require @Prop text: ResourceStr

  build() {
    ListItem() {
      Text(this.text)
        .fontColor($r('app.color.text_secondary'))
    }
    .margin({ left: 16, top: 24, bottom: 8 })
  }
}