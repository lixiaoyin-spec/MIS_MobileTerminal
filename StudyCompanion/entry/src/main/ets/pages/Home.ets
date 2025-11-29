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

  // ----------- Builder 生成导航按钮 ----------
  @Builder
  NavButton(label: string, page: string) {
    Button() {
      Text(label)
    }
    .width("25%")
    .height(50)
    .fontSize(18)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      router.pushUrl({ url: `pages/${page}` });
    })
  }

  build() {
    Column() {

      // 顶部标题
      Text("学伴领航首页")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 20 })

      // ---------- 用户信息卡片（官方正确语法） ----------
      Column() {
        Text(`用户：${this.nickname} (${this.username})`)
          .fontSize(20)
          .margin({ bottom: 6 })

        Text(`专业：${this.major}`).fontSize(16)
        Text(`年级：${this.grade}`).fontSize(16)
        Text(`兴趣标签：${this.interestTags}`).fontSize(16).margin({ bottom: 8 })
        Text(`角色：${this.role}`).fontSize(16).fontColor(Color.Grey)

        Button() {
          Text("退出登录")
        }
        .width("60%")
        .margin({ top: 20 })
        .backgroundColor(Color.Red)
        .fontColor(Color.White)
        .onClick(() => this.onLogout())
      }
      .width("90%")
      .padding(15)
      .margin({ top: 20 })
      .borderRadius(12)
      .backgroundColor(Color.White)

      Blank().height(40)

      Blank().layoutWeight(1)

      // ---------- 底部导航（官方示例写法） ----------
      Row() {
        this.NavButton("论坛", "ForumPage")
        this.NavButton("学伴推荐", "RecommendPage")
        this.NavButton("打卡", "ClockInPage")
        this.NavButton("资源上传", "ResourceUploadPage")
      }
      .width("100%")
      .height(60)
      .backgroundColor("#F2F2F2")
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#FAFAFA")
  }
}
