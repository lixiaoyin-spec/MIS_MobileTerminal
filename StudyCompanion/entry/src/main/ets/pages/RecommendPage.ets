import router from '@ohos.router';

interface RecommendUser {
  id: number;
  name: string;
  tags: string[];
}

@Entry
@Component
struct RecommendPage {

  @State recommendList: RecommendUser[] = [];

  /** 页面加载时执行 */
  aboutToAppear() {
    // TODO：未来替换为真实后端请求，这里先用示例数据方便预览
    this.loadRecommend();
  }

  /** 预留：加载推荐学伴（当前为示例数据） */
  async loadRecommend() {
    // 示例数据（方便预览）
    this.recommendList = [
      { id: 1, name: "张三", tags: ["Java", "算法"] },
      { id: 2, name: "李四", tags: ["数据库", "前端"] },
      { id: 3, name: "王五", tags: ["操作系统", "网络"] }
    ];
  }

  /** 预留：发出结伴邀请 */
  async matchWithUser(userId: number) {
    // TODO：调用后端接口发送匹配请求
    console.log("matchWithUser() 未来实现, userId =", userId);
  }

  /** 学伴推荐卡片 UI — 使用同一类型 RecommendUser */
  @Builder
  RecommendCard(user: RecommendUser) {
    Column() {
      Text(user.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Row() {
        ForEach(user.tags, (tag: string, idx: number) => {
          Text(`#${tag}`)
            .fontSize(14)
            .fontColor(Color.Grey)
            .margin({ right: 8 })
        })
      }
      .margin({ top: 6 })

      Button("结伴")
        .width(100)
      .height(36)
      .margin({ top: 12 })
      .backgroundColor("#007DFF")
      .fontColor(Color.White)
      .onClick(() => this.matchWithUser(user.id))
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 6, color: "#22000000", offsetX: 0, offsetY: 2 })
  }

  build() {
    Column() {

      /** 顶部返回栏 */
      Row() {
        Text("< 返回")
          .fontSize(18)
          .onClick(() => router.back());

        Blank().layoutWeight(1);

        Text("学伴推荐")
          .fontSize(20)
          .fontWeight(FontWeight.Bold);

        Blank().layoutWeight(1);
      }
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor("#F5F5F5")

      /** 刷新按钮 */
      Button("刷新推荐")
        .width("60%")
      .margin({ top: 20 })
      .backgroundColor(Color.Green)
      .fontColor(Color.White)
      .onClick(() => this.loadRecommend())

      /** 推荐卡片列表 */
      List() {
        ForEach(this.recommendList, (item: RecommendUser, index: number) => {
          ListItem() {
            this.RecommendCard(item)
          }
        }, (item: RecommendUser, index: number) => `${item.id}_${index}`)
      }
      .margin({ top: 20 })

    }
    .padding(20)
    .height('100%')
  }
}
