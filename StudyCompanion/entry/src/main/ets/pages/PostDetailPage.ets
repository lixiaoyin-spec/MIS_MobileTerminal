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


  /** 评论卡片 */
  @Builder
  CommentCard(item: CommentItem) {
    Column() {
      Text(item.nickname)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)

      Text(item.content)
        .fontSize(16)
        .margin({ top: 6 })

      Text(item.createTime)
        .fontSize(12)
        .fontColor(Color.Grey)
        .margin({ top: 4 })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {

      /** 顶部返回栏 **/
      Row() {
        Text("< 返回")
          .fontSize(18)
          .onClick(() => router.back())

        Blank().layoutWeight(1)

        Text("帖子详情")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Blank().layoutWeight(1)
      }
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor("#F5F5F5")

      if (this.loading) {
        Text("加载中...").fontSize(18).margin({ top: 20 })

      }

      if (this.errorMsg) {
        Text(this.errorMsg).fontColor(Color.Red).margin({ top: 20 })

      }

      /** 帖子内容 **/
      Text(this.post.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      Text("作者：" + this.post.nickname).fontSize(14).fontColor(Color.Grey)

      Text(this.post.content)
        .fontSize(18)
        .margin({ top: 20, bottom: 20 })

      /** 评论 **/
      Text("评论").fontSize(20).fontWeight(FontWeight.Bold)

      List() {
        ForEach(this.post.comments, (item: CommentItem) => {
          ListItem() { this.CommentCard(item) }
        })
      }

      /** 评论输入 **/
      TextInput({ placeholder: "写下你的评论..." })
        .width("100%")
        .height(60)
        .border({ width: 1 })
        .margin({ top: 20 })
        .onChange((v: string) => this.commentText = v)

      Button("提交评论")
        .width("60%")
        .margin({ top: 10 })
        .backgroundColor("#007DFF")
        .fontColor(Color.White)
        .onClick(() => this.submitComment())

      if (this.errorMsg) {
        Text(this.errorMsg).fontColor(Color.Red).margin({ top: 10 })
      }

    }
    .padding(20)
  }
}
