@Entry
@Component
struct Index {
  @State text: string = 'email@mail.com'

  private menuItems: Array<NavigationMenuItem> = [
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_add')),
      icon: 'resources/base/media/ic_public_add.svg',
      action: () => {}
    },
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_search')),
      icon: 'resources/base/media/ic_public_search.svg',
      action: () => {}
    },
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_more')),
      icon: 'resources/base/media/ic_public_more.svg',
      action: () => {}
    }
  ]

  build() {
    Navigation() {
      Scroll() {
        Column() {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
            Row() {
              Column() {
                Text('Microsoft')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                Text(this.text)
                  .fontSize(15)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('123 456')
                .fontWeight(600)
                .fontSize(32)
            }
            .backgroundColor('white')
            .borderRadius(16)
            .width('95%')
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 16
            })
            .margin({ bottom: 10 })
          })
        }
      }
    }
    .title($r('app.string.mainPage_title'))
    .menus(this.menuItems)
    .backgroundColor('#F1F2F3')
  }
}