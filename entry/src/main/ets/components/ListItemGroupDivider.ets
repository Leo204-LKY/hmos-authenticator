@Component
export struct ListItemGroupDivider {
  build() {
    Divider()
      .strokeWidth(1)
      .color($r('app.color.divider'))
      .width('100%')
  }
}