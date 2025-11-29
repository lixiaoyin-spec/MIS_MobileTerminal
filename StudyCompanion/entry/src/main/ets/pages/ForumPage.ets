import router from '@ohos.router';
import { HttpClient } from '../common/HttpClient';
import { ApiResponse } from '../common/ApiResponse';

export interface ForumPost {
  id: number;
  nickname: string;
  title: string;
  content: string;
  createTime: string;
}

@Entry
@Component
struct ForumPage {
  @State posts: ForumPost[] = [];
  @State loading: boolean = false;
  @State errorMsg: string = "";

  async aboutToAppear() {
    this.loadPosts();
  }

  async loadPosts() {
    this.loading = true;
    this.errorMsg = "";

    try {
      const token = AppStorage.get("token") as string | undefined;

      // 使用明确的接口类型，不使用对象字面量作为泛型
      const res: ApiResponse<ForumPost[]> =
        await HttpClient.get<ApiResponse<ForumPost[]>>("/api/post/list", token);

      if (res.code !== 200) {
        this.errorMsg = res.msg ?? "加载失败";
        return;
      }

      this.posts = res.data ?? [];

    } catch (e) {
      this.errorMsg = "网络错误";
    } finally {
      this.loading = false;
    }
  }

  @Builder
  PostCard(item: ForumPost) {
    Column() {
      Text(item.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Text(item.nickname)
        .fontSize(14)
        .fontColor(Color.Grey)

      Text(item.content)
        .maxLines(2)
        .margin({ top: 6 })
        .fontSize(16)

      Text(item.createTime)
        .fontSize(12)
        .fontColor(Color.Grey)
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      router.pushUrl({
        url: "pages/PostDetailPage",
        params: { id: item.id }
      })
    })
  }

  build() {
    Column() {

      // 顶部标题
      Text("论坛")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      if (this.loading) {
        Text("加载中...").fontSize(18)
      } else if (this.errorMsg) {
        Text(this.errorMsg).fontColor(Color.Red)
      } else {
        List() {
          ForEach(this.posts, (item: ForumPost, index: number) => {
            ListItem() { this.PostCard(item) }
          })
        }
      }

      Button("发帖")
        .margin({ top: 20 })
        .onClick(() => router.pushUrl({ url: "pages/CreatePostPage" }))

      // ======== 底部导航栏 ========
      Blank().layoutWeight(1)  // 占位，把底部栏压到底部

      Row() {
        // Home 按钮
        Column() {
          Text("首页").fontSize(14)
            // 点击返回 Home
            .onClick(() => router.replaceUrl({ url: "pages/Home" }))
        }.width("33%").alignItems(HorizontalAlign.Center)

        // Forum 当前页面
        Column() {
          Text("论坛").fontSize(14).fontColor(Color.Blue)
        }.width("33%").alignItems(HorizontalAlign.Center)

        // Profile
        Column() {
          Text("我的").fontSize(14)
            .onClick(() => router.replaceUrl({ url: "pages/ProfilePage" }))
        }.width("33%").alignItems(HorizontalAlign.Center)
      }
      .height(60)
      .backgroundColor(Color.White)
      .border({ width: 1, color: '#ddd' })
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ bottom: 10, top: 10 })
    }
    .width("100%")
  }
}
