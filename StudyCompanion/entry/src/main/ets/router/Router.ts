import router from '@ohos.router';

export default class AppRouter {
  static push(page: string, params?: Object) {
    router.pushUrl({ url: page, params: params ?? {} });
  }

  static replace(page: string, params?: Object) {
    router.replaceUrl({ url: page, params: params ?? {} });
  }

  static back() {
    router.back();
  }
}
