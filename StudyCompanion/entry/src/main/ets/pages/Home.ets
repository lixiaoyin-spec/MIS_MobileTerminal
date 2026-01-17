import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { UserStore } from '../store/UserStore';

@Entry
@Component
struct HomePage {

  @State username: string = "";
  @State nickname: string = "";
  @State major: string = "";
  @State grade: number = 0;
  @State interestTags: string = "";
  @State role: string = "";

  private userStore: UserStore = new UserStore();
  private context: common.Context = getContext(this);

  async aboutToAppear() {
    await this.userStore.init(this.context);

    if (!this.userStore.isLoggedIn()) {
      router.replaceUrl({ url: "pages/LoginPage" });
      return;
    }

    this.username = this.userStore.username;
    this.nickname = this.userStore.nickname;
    this.major = this.userStore.major;
    this.grade = this.userStore.grade;
    this.interestTags = this.userStore.interestTags;
    this.role = this.userStore.role;
  }

  onLogout() {
    this.userStore.logout();
    router.replaceUrl({ url: "pages/LoginPage" });
  }

  // ----------- Builder 生成功能卡片 ----------
  @Builder
  NavCard(label: string, iconStr: string, page: string, bgColor: string) {
    Column() {
      Text(iconStr)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor(bgColor)
        .width(50)
        .height(50)
        .borderRadius(25)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 })

      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
    }
    .width('44%') // 两列布局
    .height(110)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .margin(8)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
    .onClick(() => {
      router.pushUrl({ url: `pages/${page}` });
    })
  }

  build() {
    Column() {
      // 顶部背景区域
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height(220)
          .linearGradient({
            angle: 180,
            colors: [[0x1e3c72, 0.0], [0x2a5298, 1.0]]
          })
          .borderRadius({ bottomLeft: 30, bottomRight: 30 })

        Column() {
          Text("学伴领航")
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: 40, left: 20 })
          
          Text(`欢迎回来，${this.nickname || this.username}`)
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 8, left: 20 })
        }
      }
      .height(220)
      .width('100%')

      // 用户信息卡片 (浮动在背景之上)
      Column() {
        Row() {
          Column() {
            Text(this.nickname || "用户")
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
            Text(this.role === 'teacher' ? '教师' : '学生')
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor('#FF9800')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Button("退出")
            .height(28)
            .fontSize(12)
            .backgroundColor('rgba(255, 0, 0, 0.1)')
            .fontColor(Color.Red)
            .onClick(() => this.onLogout())
        }
        .width('100%')
        .padding({ bottom: 12 })
        .border({ width: { bottom: 1 }, color: '#eee' })

        Row() {
          Column() {
            Text(this.major || "暂无专业")
              .fontSize(14)
              .fontColor('#666')
            Text("专业")
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }.layoutWeight(1)

          Column() {
            Text(String(this.grade || 0))
              .fontSize(14)
              .fontColor('#666')
            Text("年级")
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }.layoutWeight(1)

          Column() {
            Text(this.interestTags || "无")
              .fontSize(14)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text("标签")
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }.layoutWeight(1)
        }
        .padding({ top: 12 })
      }
      .width("90%")
      .padding(20)
      .margin({ top: -80 }) // 负边距实现重叠效果
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.1)', offsetY: 4 })

      // 功能导航区域
      Text("功能服务")
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .margin({ top: 20, bottom: 10 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        this.NavCard("论坛交流", "论", "ForumPage", "#4CAF50")
        this.NavCard("学伴推荐", "伴", "RecommendPage", "#2196F3")
        this.NavCard("AI助手", "AI", "AiChatPage", "#9C27B0")
        this.NavCard("每日打卡", "卡", "ClockInPage", "#FF9800")
        this.NavCard("资源上传", "传", "ResourceUploadPage", "#607D8B")
      }
      .width('100%')
      .padding({ left: 10, right: 10 })

    }
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
