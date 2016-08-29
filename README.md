# 複雑なJSONをレンダリングするところ選手権

## 候補者
- ActiveModelSerializer

### 特徴をざっくり

#### ActiveModelSerializer
- [v0.10.xのドキュメント](https://github.com/rails-api/active_model_serializers/tree/master/docs)
- json:apiの使用にしたがってparse, validateするjsonapi gemに依存している

##### [json:api](http://jsonapi.org/)
- APIで返すjson形式の標準化をしようとしている
- v1.0 stable
- アンチ自転車小屋の議論(CoC)

##### いったん[getting start](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/getting_started.md)する
- 基本はモデルと1:1
  - モデルがネームスペース切ってたら、serializerもネームスペースをあわせる
- 直感的
  - クラス作って、attribute定義する
- ApplicationSerializerも定義できる
  - まあ当然
- Adapterでjsonのフォーマットが決まる？
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/general/adapters.md
  - デフォルトではattributesアダプターで特に仕様には則っていない
    - ルートキーなしの割りとよく見るやつ
  - ルートキーある版とか、jsonapi仕様とか、ある
  - 自分でも書ける(つらそう)
- ルートキーをcamelとかback camelとかunder scoreとか変更できる
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/general/key_transforms.md

- serializer上でmethodを定義
  - attributeをoverrideできる
- アソシエーションタイプ
  - has_one, has_many, belongs_to
- いくつかオプションを渡せる
  - jsonのkey
  - serializer: モデルに紐付いていないserializerを指定できる
  - if, unless
  - virtual_value: ダミーデータ使える
    - アソシエーションが定義されていないとダメ
    - attributeごとにダミーデータを指定できたりしない
  - polymorphic関連もよしなにやってくれる
  - blockも渡せる

- 総じてActiveModelって感じ

- caching
  - railsのfragment_cacheっぽい
  - jsonのkeyごととかで設定できる
  - https://github.com/rails-api/active_model_serializers/issues/1586
    - キャッシュ使うときはちゃんとベンチ取る必要ありそう

- 基本はjsonapiに合わせて実装されていきそう
- jsonapiに乗っかるんだったら最高だと思う

- scope
  - action_controllerのインスタンス変数はviewテンプレートじゃないので受け取れない
  - current_user的なscopeを取得したいときはcontroller側にメソッドを生やす

```ruby
helper_method :current_member
serialization_scope :current_member # デフォルトはcurrent_user

private

def current_member
  @authenticated_member
end
```

- def name; endみたいにattribute nameでmethod定義するより、attributeにブロック渡すほうが、良さそう
  - def hogeはあくまでメソッドとして、とどめて、attributeに変更加えたいときはblock渡すべき

```ruby
def name
object.name << "!!!"
end

attribute name do # ActiveModel::Serializer::Attributes::ClassMethods#attribute
object.name << "!!!"
end
```

- render json したときにrailsはまずserializerを読みにいく
- serializerをrender jsonオプションに渡して指定できる
  - each_serializerとserializerオプションがある

- Non ActiveRecordオブジェクトはどうやってシリアライズする？
  - いわゆるvalue object的なやつ
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/howto/serialize_poro.md
  - ActiveModelSerializers::Modelを継承させると楽に実装できそう
    - ただ、includeではなく継承なので、使いづらい部分はある
  - ユースケース自体は少なそう
  - jbuilderの手軽さに近いものを感じる
- renderのオプションで特定のフィールドを指定できる
  - fields: { users: [:name] }
- jsonのkeyはなんだかんだいい感じに指定できる
- instrumentationも提供されている
- 独自Adapterを書くのはそんなに難しくなさそう
  - meta入れたいだけだったら jsonアダプター使うのが良さそう
    - metaの中身はハッシュで指定できそう
  - いろいろひっくるめてASM Wayに乗りたいんであればjsonapiアダプターが良さそう
  - metaを許容する設計にすれば良さそう