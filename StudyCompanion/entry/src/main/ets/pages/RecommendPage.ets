import router from '@ohos.router';
import { HttpClient } from '../common/HttpClient';
import { UserStore } from '../store/UserStore';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';

interface RecommendUser {
  id: number;
  name: string;
  tags: string[];
}

interface RecommendResponse {
  code: number;
  msg: string;
  data: PartnerVO[];
}

interface PartnerVO {
  id: number;
  nickname: string;
  username: string;
  interestTags: string;
}

@Entry
@Component
struct RecommendPage {

  @State recommendList: RecommendUser[] = [];
  @State private userStore: UserStore = new UserStore();

  /** 页面加载时执行 */
  async aboutToAppear() {
    await this.userStore.init(getContext(this) as common.Context);
    this.loadRecommend();
  }

  /** 加载推荐学伴（真实后端请求） */
  async loadRecommend() {
    try {
      const token = this.userStore.token;
      if (!token) {
        promptAction.showToast({ message: "请先登录" });
        return;
      }

      // 调用后端接口 GET /api/partner/recommend?token=...
      const res = await HttpClient.get<RecommendResponse>('/api/partner/recommend?token=' + token);

      if (res.code === 200) {
        // 映射后端数据 (PartnerVO) 到前端模型
        this.recommendList = res.data.map((item: PartnerVO) => {
          let user: RecommendUser = {
            id: item.id,
            name: item.nickname || item.username,
            tags: item.interestTags ? item.interestTags.split(',') : []
          };
          return user;
        });

        
        if (this.recommendList.length === 0) {
             promptAction.showToast({ message: "暂无推荐学伴" });
        }
      } else {
        promptAction.showToast({ message: res.msg || "获取推荐失败" });
      }
    } catch (e) {
      console.error("Load recommend failed", e);
      promptAction.showToast({ message: "网络错误，请检查连接" });
    }
  }

  /** 预留：发出结伴邀请 */
  async matchWithUser(userId: number) {
    // TODO：调用后端接口发送匹配请求
    promptAction.showToast({ message: `已向用户(ID:${userId})发送邀请` });
  }

  /** 学伴推荐卡片 UI — 使用同一类型 RecommendUser */
  @Builder
  RecommendCard(user: RecommendUser) {
    Column() {
      Row() {
        // 头像占位
        Image($r('app.media.startIcon')) 
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 10 })
          // 如果没有 app_icon，可以使用背景色代替
          .backgroundColor('#eee') 

        Column() {
          Text(user.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Row() {
            ForEach(user.tags, (tag: string, idx: number) => {
              Text(`#${tag}`)
                .fontSize(12)
                .fontColor('#666')
                .backgroundColor('#f0f0f0')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 6 })
            })
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Button("结伴")
        .width('100%')
        .height(36)
        .margin({ top: 12 })
        .backgroundColor("#007DFF")
        .fontColor(Color.White)
        .onClick(() => this.matchWithUser(user.id))
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: "#11000000", offsetX: 0, offsetY: 2 })
  }

  build() {
    Column() {

      /** 顶部返回栏 */
      Row() {
        Text("<")
          .fontSize(24)
          .padding(10)
          .onClick(() => router.back());

        Text("学伴推荐")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 44 }) // 平衡左边返回按钮的宽度
      }
      .height(56)
      .width('100%')
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: "#11000000", offsetY: 1 })

      /** 刷新按钮区域 */
      Row() {
         Text("发现可能感兴趣的学伴")
           .fontSize(14)
           .fontColor('#999')
         
         Blank()

         Button("刷新")
           .height(30)
           .fontSize(14)
           .backgroundColor(Color.Transparent)
           .fontColor('#007DFF')
           .onClick(() => this.loadRecommend())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })

      /** 推荐卡片列表 */
      if (this.recommendList.length === 0) {
        Column() {
           Image($r('app.media.startIcon'))
             .width(80)
             .height(80)
             .opacity(0.3)
             .margin({bottom: 16})
             
           Text("暂无推荐学伴")
             .fontSize(18)
             .fontColor('#666')
             .margin({bottom: 8})
             
           Text("快去完善个人标签或邀请好友加入吧")
             .fontSize(14)
             .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.recommendList, (item: RecommendUser, index: number) => {
            ListItem() {
              this.RecommendCard(item)
            }
          }, (item: RecommendUser, index: number) => `${item.id}_${index}`)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .edgeEffect(EdgeEffect.Spring) // 增加回弹效果
      }

    }
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景
  }
}
