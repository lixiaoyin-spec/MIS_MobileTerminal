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
      Row() {
        // Avatar placeholder (Circle with first letter)
        Text(item.nickname.substring(0, 1))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#007DFF')
          .width(32)
          .height(32)
          .borderRadius(16)
          .textAlign(TextAlign.Center)
          .margin({ right: 12 })
        
        Column() {
          Text(item.nickname)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          Text(item.createTime)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 2 })
        }.alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(item.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000')
        .width('100%')
        .margin({ bottom: 8 })

      Text(item.content)
        .fontSize(15)
        .fontColor('#666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .lineHeight(22)
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12, left: 16, right: 16 })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
    .onClick(() => {
      router.pushUrl({
        url: "pages/PostDetailPage",
        params: { id: item.id }
      })
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text("<")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            router.back();
          })
        
        Text("学习论坛")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
        
        // 发帖按钮
        Text("+ 发帖")
          .fontSize(16)
          .fontColor('#007DFF')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => router.pushUrl({ url: "pages/CreatePostPage" }))
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
      .zIndex(1)

      if (this.loading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#007DFF')
          Text("加载中...").fontSize(14).fontColor('#999').margin({ top: 10 })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else if (this.errorMsg) {
        Column() {
          Text(this.errorMsg).fontSize(16).fontColor('#999')
          Button("重试")
            .margin({ top: 16 })
            .onClick(() => this.loadPosts())
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.posts, (item: ForumPost, index: number) => {
            ListItem() { this.PostCard(item) }
          })
          ListItem().height(80) // 底部留白
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 16 })
        .backgroundColor('#F5F7FA') // 浅灰背景
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#F5F7FA')
  }
}
