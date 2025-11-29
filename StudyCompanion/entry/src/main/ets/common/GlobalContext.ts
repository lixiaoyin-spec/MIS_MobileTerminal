export class GlobalContext {
  private static abilityContext: any;

  static setAbilityContext(ctx: any) {
    GlobalContext.abilityContext = ctx;
  }

  static getAbilityContext<T>(): T {
    return GlobalContext.abilityContext as T;
  }
}
