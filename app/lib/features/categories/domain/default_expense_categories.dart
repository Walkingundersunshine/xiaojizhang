final class DefaultSubcategory {
  const DefaultSubcategory(this.id, this.name);

  final String id;
  final String name;
}

final class DefaultCategoryGroup {
  const DefaultCategoryGroup(this.id, this.name, this.children);

  final String id;
  final String name;
  final List<DefaultSubcategory> children;
}

abstract final class DefaultExpenseCategories {
  static const groups = <DefaultCategoryGroup>[
    DefaultCategoryGroup('food', '餐饮', [
      DefaultSubcategory('food.breakfast', '早餐'),
      DefaultSubcategory('food.lunch', '午餐'),
      DefaultSubcategory('food.dinner', '晚餐'),
      DefaultSubcategory('food.delivery', '外卖'),
      DefaultSubcategory('food.drinks', '饮品'),
      DefaultSubcategory('food.snacks', '零食'),
      DefaultSubcategory('food.gathering', '聚餐'),
      DefaultSubcategory('food.groceries', '买菜'),
    ]),
    DefaultCategoryGroup('transport', '交通', [
      DefaultSubcategory('transport.public', '公交地铁'),
      DefaultSubcategory('transport.taxi', '出租网约车'),
      DefaultSubcategory('transport.train', '火车'),
      DefaultSubcategory('transport.flight', '飞机'),
      DefaultSubcategory('transport.car', '驾车用车'),
      DefaultSubcategory('transport.cycling', '骑行'),
      DefaultSubcategory('transport.parking', '停车'),
      DefaultSubcategory('transport.toll', '过路费'),
    ]),
    DefaultCategoryGroup('housing', '居住', [
      DefaultSubcategory('housing.rent', '房租'),
      DefaultSubcategory('housing.mortgage', '房贷'),
      DefaultSubcategory('housing.property', '物业'),
      DefaultSubcategory('housing.water', '水费'),
      DefaultSubcategory('housing.electricity', '电费'),
      DefaultSubcategory('housing.gas', '燃气'),
      DefaultSubcategory('housing.internet', '网络通信'),
      DefaultSubcategory('housing.repair', '维修'),
      DefaultSubcategory('housing.supplies', '家居用品'),
    ]),
    DefaultCategoryGroup('shopping', '购物', [
      DefaultSubcategory('shopping.clothing', '服饰鞋包'),
      DefaultSubcategory('shopping.digital', '数码电器'),
      DefaultSubcategory('shopping.daily', '日用品'),
      DefaultSubcategory('shopping.beauty', '美妆护理'),
      DefaultSubcategory('shopping.appliance', '家电'),
      DefaultSubcategory('shopping.gift', '礼品'),
      DefaultSubcategory('shopping.other', '其他购物'),
    ]),
    DefaultCategoryGroup('entertainment', '娱乐', [
      DefaultSubcategory('entertainment.show', '电影演出'),
      DefaultSubcategory('entertainment.games', '游戏'),
      DefaultSubcategory('entertainment.media', '音乐视频'),
      DefaultSubcategory('entertainment.fitness', '运动健身'),
      DefaultSubcategory('entertainment.travel', '旅行度假'),
      DefaultSubcategory('entertainment.hobby', '兴趣爱好'),
      DefaultSubcategory('entertainment.subscription', '会员订阅'),
    ]),
    DefaultCategoryGroup('health', '医疗健康', [
      DefaultSubcategory('health.clinic', '挂号诊疗'),
      DefaultSubcategory('health.medicine', '药品'),
      DefaultSubcategory('health.checkup', '体检'),
      DefaultSubcategory('health.dental', '牙科'),
      DefaultSubcategory('health.eye', '眼科'),
      DefaultSubcategory('health.recovery', '康复护理'),
      DefaultSubcategory('health.supplies', '健康用品'),
    ]),
    DefaultCategoryGroup('learning', '学习成长', [
      DefaultSubcategory('learning.books', '书籍'),
      DefaultSubcategory('learning.courses', '课程'),
      DefaultSubcategory('learning.exams', '考试'),
      DefaultSubcategory('learning.training', '培训'),
      DefaultSubcategory('learning.stationery', '文具'),
      DefaultSubcategory('learning.software', '软件工具'),
    ]),
    DefaultCategoryGroup('social', '人情社交', [
      DefaultSubcategory('social.treat', '请客'),
      DefaultSubcategory('social.cash_gift', '礼金'),
      DefaultSubcategory('social.red_packet', '红包'),
      DefaultSubcategory('social.gift', '礼物'),
      DefaultSubcategory('social.gathering', '聚会活动'),
      DefaultSubcategory('social.charity', '公益捐赠'),
    ]),
    DefaultCategoryGroup('family', '家庭与宠物', [
      DefaultSubcategory('family.childcare', '育儿'),
      DefaultSubcategory('family.eldercare', '赡养'),
      DefaultSubcategory('family.pet_food', '宠物食品'),
      DefaultSubcategory('family.pet_medical', '宠物医疗'),
      DefaultSubcategory('family.pet_supplies', '宠物用品'),
      DefaultSubcategory('family.other', '家庭其他'),
    ]),
    DefaultCategoryGroup('finance', '金融支出', [
      DefaultSubcategory('finance.bank_fee', '银行手续费'),
      DefaultSubcategory('finance.interest', '利息'),
      DefaultSubcategory('finance.insurance', '保险'),
      DefaultSubcategory('finance.investment_fee', '投资费用'),
      DefaultSubcategory('finance.other', '其他金融费用'),
    ]),
    DefaultCategoryGroup('government', '税费与政务', [
      DefaultSubcategory('government.tax', '税款'),
      DefaultSubcategory('government.document', '证件办理'),
      DefaultSubcategory('government.administration', '行政费用'),
      DefaultSubcategory('government.other', '其他税费'),
    ]),
    DefaultCategoryGroup('business', '工作经营', [
      DefaultSubcategory('business.office', '办公用品'),
      DefaultSubcategory('business.travel', '差旅'),
      DefaultSubcategory('business.entertainment', '招待'),
      DefaultSubcategory('business.logistics', '物流'),
      DefaultSubcategory('business.marketing', '推广'),
      DefaultSubcategory('business.professional', '专业服务'),
      DefaultSubcategory('business.other', '其他经营支出'),
    ]),
    DefaultCategoryGroup('other', '其他', [
      DefaultSubcategory('other.uncategorized', '无法归类'),
      DefaultSubcategory('other.temporary', '临时支出'),
    ]),
  ];
}
