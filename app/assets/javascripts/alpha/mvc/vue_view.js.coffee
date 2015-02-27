#
# @fileoverview Data binding view class with memory management like Backbone.View.
#
alpha.export 'alpha.mvc.VueView'

# ビュービューのライフサイクル
# - initialize
#     ビューの生成
# - render
#     ビューの描画、再描画
# - decorate
#     既存のHTMLへのアタッチ
# - enterDocument
#     DOMツリーに追加された
# - childDocument
#     DOMツリーへ子コンポーネントを差し込む
# - exitDocument
#     DOMツリーから外れた
# - dispose
#     ビューの破棄
#
# @extends {alpha.mvc.View}
class alpha.mvc.VueView extends alpha.mvc.View

  vue: null

  # @override
  # @param {Object=} opt_options .
  constructor: (opt_options) ->
    super(opt_options)

  # データバインディングするHTML要素を指定
  # id, class どちらでも可
  elementBinding: ->
    return ''

  # データバインディング用データモデル
  # Vue#$dataに対応
  dataBinding: ->
    return {}

  # データバインディングされているHTML要素でEvent発火時に呼び出すメソッドの定義
  # Vue#methods
  methodsBinding: ->
    return {}

  # 計算ロジック用プロパティ
  # Vue#computed
  computedBinding: ->
    return {}

  # custom filter, validator
  # default filters: http://vuejs.org/api/filters.html
  filtersBinding: ->
    return {}

  # その他のプロパティ/メソッドをViewModelへ流し込む
  otherBinding: ->
    return {}

  # @override
  renderEvery: ->
    @$el.hide()

  # when you use vueview, you can put 'after enterdocument processing' in arguments.
  # @override
  # @param {Function} callback .
  enterDocument: (callback=->) ->
    super
    @vue or= new Vue(
      el: @elementBinding()
      data: @dataBinding()
      methods: @methodsBinding()
      computed: @computedBinding()
      filters: @filtersBinding()
      other: @otherBinding()
    )
    @vue.$vueView = @
    Vue.nextTick =>
      @$el.show()
      callback()
      @childDocument()

  childDocument: ->

  # @override
  dispose: ->
    if @vue
      @vue.$vueView = null
      @vue.$destroy()
      @vue = null
    super

  addChildTemplateFunction: (html, childTemplateName) ->
    childTemplate = JST[childTemplateName]
    if childTemplate and _.isFunction(childTemplate)
      child = childTemplate.call(childTemplate,
            _.extend(@getTemplateData())
      )
      html = child + html

    html
