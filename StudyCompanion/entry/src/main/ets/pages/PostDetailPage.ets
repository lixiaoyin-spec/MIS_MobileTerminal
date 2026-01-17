import router from '@ohos.router';
import { HttpClient } from '../common/HttpClient';
import { ApiResponse } from '../common/ApiResponse';

export interface CommentItem {
  id: number;
  postId: number;
  nickname: string;
  content: string;
  createTime: string;
}

export interface ForumPostDetail {
  id: number;
  title: string;
  content: string;
  nickname: string;
  viewCount: number;
  createTime: string;
  updateTime: string;
  comments: CommentItem[];
}

interface RouteParams {
  id: number | string;
}

interface GeneratedObjectLiteralInterface_1 {
  postId: number;
  content: string;
}

interface GeneratedObjectLiteralInterface_2 {
  postId: number;
  content: string;
  token: string;
}

@Entry
@Component
struct PostDetailPage {
  @State postId: number = 0;

  @State post: ForumPostDetail = {
    id: 0,
    title: "",
    content: "",
    nickname: "",
    viewCount: 0,
    createTime: "",
    updateTime: "",
    comments: []
  };

  @State commentText: string = "";
  @State errorMsg: string = "";
  @State loading: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    const idVal = Number(params?.id ?? 0);
    this.postId = isNaN(idVal) ? 0 : idVal;

    if (this.postId > 0) {
      this.loadPostDetail();
    } else {
      this.errorMsg = "无效的帖子 ID";
    }
  }

  /** 加载帖子详情（包含评论） */
  async loadPostDetail() {
    const token = AppStorage.get("token") as string | undefined;
    if (!token) {
      this.errorMsg = "未登录";
      return;
    }

    this.loading = true;

    try {
      const res = await HttpClient.get<ApiResponse<ForumPostDetail>>(
        `/api/post/detail?postId=${this.postId}`,
        token
      );

      if (res.code === 200 && res.data) {
        this.post = res.data;
      } else {
        this.errorMsg = res.msg || "加载帖子失败";
      }
    } catch (e) {
      console.error("loadPostDetail error", e);
      this.errorMsg = "网络错误";
    } finally {
      this.loading = false;
    }
  }

  /** 提交评论 */
  async submitComment() {
    const token = AppStorage.get("token") as string | undefined;
    if (!token) {
      this.errorMsg = "未登录";
      return;
    }

    if (!this.commentText.trim()) {
      this.errorMsg = "评论不能为空";
      return;
    }

    try {
      const body: GeneratedObjectLiteralInterface_2 = {
        postId: this.postId,
        content: this.commentText.trim(),
        token: token   // ★★★ 必须加上！！！
      };

      const res = await HttpClient.postJson<ApiResponse<null>>(
        "/api/comment/add",
        body,
        token
      );

      if (res.code === 200) {
        this.commentText = "";
        this.loadPostDetail(); // 刷新评论
      } else {
        this.errorMsg = res.msg || "评论失败";
      }
    } catch (e) {
      console.error("submitComment error", e);
      this.errorMsg = "提交评论失败";
    }
  }


  @Builder
  CommentCard(item: CommentItem) {
    Row() {
      // Avatar placeholder
      Text(item.nickname.substring(0, 1))
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .width(32)
        .height(32)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(item.nickname)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          
          Blank()
          
          Text(item.createTime)
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')
        .margin({ bottom: 4 })

        Text(item.content)
          .fontSize(15)
          .fontColor('#333')
          .lineHeight(20)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
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
        
        Text("帖子详情")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 44 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
      .zIndex(1)

      List() {
        // 帖子内容区域
        ListItem() {
          Column() {
            Text(this.post.title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000')
              .margin({ bottom: 12 })
              .width('100%')

            Row() {
              Text(this.post.nickname)
                .fontSize(14)
                .fontColor('#666')
                .fontWeight(FontWeight.Medium)
              
              Text(" · " + this.post.createTime)
                .fontSize(12)
                .fontColor('#999')
            }
            .width('100%')
            .margin({ bottom: 20 })

            Text(this.post.content)
              .fontSize(16)
              .fontColor('#333')
              .lineHeight(24)
              .width('100%')
          }
          .padding(20)
          .backgroundColor(Color.White)
          .margin({ bottom: 10 })
        }

        // 评论区标题
        ListItem() {
          Text(`评论 (${this.post.comments.length})`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .padding({ left: 16, top: 16, bottom: 12 })
        }

        // 评论列表
        ForEach(this.post.comments, (item: CommentItem) => {
          ListItem() { this.CommentCard(item) }
          .padding({ left: 16, right: 16 })
        })

        // 底部留白，防止被输入框遮挡
        ListItem().height(80)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F7FA')

      // 底部评论输入区
      Column() {
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(12)
            .fontColor(Color.Red)
            .margin({ bottom: 8 })
            .width('100%')
        }

        Row() {
          TextInput({ placeholder: "写下你的评论...", text: this.commentText })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F0F2F5')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .margin({ right: 12 })
            .onChange((v: string) => this.commentText = v)

          Button("发送")
            .height(36)
            .fontSize(14)
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .borderRadius(18)
            .onClick(() => this.submitComment())
            .enabled(!this.loading)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#EEE' })
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#F5F7FA')
  }
}
