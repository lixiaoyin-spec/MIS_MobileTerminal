import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '../common/ErrorTypes';

// 适配后端登录返回的用户信息结构
export interface UserInfo {
  id: number;
  username: string;
  nickname: string;
  major: string;
  grade: number;
  interestTags: string;
  role: string;
  token: string;
}

// 适配后端登录接口整体返回结构
export interface LoginResponse {
  code: number;
  msg: string;
  data: UserInfo;
}

// 适配后端注册接口返回结构
export interface RegisterResponse {
  code: number;
  msg: string;
}

export class UserStore {
  private pref?: preferences.Preferences;
  // 扩展存储用户信息字段
  private _token: string = "";
  private _username: string = "";
  private _nickname: string = "";
  private _major: string = "";
  private _grade: number = 0;
  private _interestTags: string = "";
  private _role: string = "";

  // 初始化 Preferences，需要 context
  async init(context: common.Context): Promise<void> {
    const options: preferences.Options = { name: "user_pref" };
    const p = preferences.getPreferencesSync(context, options);
    if (!p) {
      console.warn("Preferences 初始化失败，context 可能无效");
      return;
    }
    this.pref = p;

    // 读取所有保存的用户信息
    const savedToken = this.pref.getSync("token", "");
    const savedUser = this.pref.getSync("username", "");
    const savedNickname = this.pref.getSync("nickname", "");
    const savedMajor = this.pref.getSync("major", "");
    const savedGrade = this.pref.getSync("grade", 0);
    const savedTags = this.pref.getSync("interestTags", "");
    const savedRole = this.pref.getSync("role", "");

    if (typeof savedToken === "string") this._token = savedToken;
    if (typeof savedUser === "string") this._username = savedUser;
    if (typeof savedNickname === "string") this._nickname = savedNickname;
    if (typeof savedMajor === "string") this._major = savedMajor;
    if (typeof savedGrade === "number") this._grade = savedGrade;
    if (typeof savedTags === "string") this._interestTags = savedTags;
    if (typeof savedRole === "string") this._role = savedRole;
  }

  // 暴露所有用户信息的 getter
  get token(): string { return this._token; }
  get username(): string { return this._username; }
  get nickname(): string { return this._nickname; }
  get major(): string { return this._major; }
  get grade(): number { return this._grade; }
  get interestTags(): string { return this._interestTags; }
  get role(): string { return this._role; }

  isLoggedIn(): boolean {
    return this._token.length > 0;
  }

  async login(username: string, password: string): Promise<LoginResponse> {
    // 调用登录接口，匹配后端返回结构
    const res = await (await import('../common/HttpClient')).HttpClient.postJson<LoginResponse>(
      "/api/user/login",
      { username, password }
    );

    // 校验接口返回码，抛出自定义业务错误
    if (res.code !== 200) {
      throw new BusinessError(res.msg || "登录失败", res.code);
    }

    // 解析用户信息
    const userInfo = res.data;
    this._token = userInfo.token;
    this._username = userInfo.username;
    this._nickname = userInfo.nickname;
    this._major = userInfo.major;
    this._grade = userInfo.grade;
    this._interestTags = userInfo.interestTags;
    this._role = userInfo.role;

    // 保存所有用户信息到偏好设置
    if (this.pref) {
      this.pref.putSync("token", this._token);
      this.pref.putSync("username", this._username);
      this.pref.putSync("nickname", this._nickname);
      this.pref.putSync("major", this._major);
      this.pref.putSync("grade", this._grade);
      this.pref.putSync("interestTags", this._interestTags);
      this.pref.putSync("role", this._role);
      this.pref.flushSync();
    } else {
      console.warn("Preferences 未初始化，不保存登录信息");
    }

    return res;
  }

  logout(): void {
    // 清空所有用户信息
    this._token = "";
    this._username = "";
    this._nickname = "";
    this._major = "";
    this._grade = 0;
    this._interestTags = "";
    this._role = "";

    if (this.pref) {
      this.pref.putSync("token", "");
      this.pref.putSync("username", "");
      this.pref.putSync("nickname", "");
      this.pref.putSync("major", "");
      this.pref.putSync("grade", 0);
      this.pref.putSync("interestTags", "");
      this.pref.putSync("role", "");
      this.pref.flushSync();
    }
  }
}