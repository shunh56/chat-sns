import 'dart:io';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/providers/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final termOfUseProvider = StateProvider((ref) => false);
final signupProcessProvider = StateProvider.autoDispose((ref) => false);
String platformOS = Platform.isAndroid ? "Android" : "iOS";

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    showPolicyDialog(BuildContext context, WidgetRef ref) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(0),
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              width: 324,
              height: 480,
              decoration: BoxDecoration(
                color: const Color(0xFF444444),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                children: [
                  Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          backgroundColor: ThemeColor.text,
                          child: Icon(
                            Icons.gavel,
                            size: 24,
                            color: ThemeColor.text,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Center(
                        child: Text(
                          "利用規約",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: ThemeColor.text),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "サービス利用規約",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "本サービス利用規約（以下、「本規約」と称します）は、当社の様々なウェブサイト、API、メール通知、アプリケーション、ボタン、ウィジェット、広告、およびeコマースサービスなどのYoloのサービス、ならびに本サービスにアップロード、ダウンロードまたは表示される情報、テキスト、リンク、グラフィック、写真、その他のコンテンツにアクセスし、利用する場合に適用されます。本サービスを利用することによって、ユーザーは本規約に拘束されることに同意したことになります。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "利用できる対象",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "いかなる場合においても、本サービスを利用するためには13歳以上でなければならないものとします。また、本サービスを利用できるのは、Yoloと拘束力のある契約を締結することに同意し、法律によりサービスを受けることが禁止されていない者に限ります。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "プライバシーポリシー",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "本サービスのプライバシーポリシーは、Yoloをご使用いただく際に提供された情報の取り扱いについて説明しています。ユーザーは、本サービスを利用することによって、Yoloおよびその関係会社がこれら情報を保管、処理、使用するために、これら情報の収集および使用（プライバシーポリシーの定めに従って）に同意することを理解しているものとします。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "本サービス上のコンテンツ",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "ユーザーは、適用される法令や規則への遵守を含め、本サービスの利用および自身が提供する情報に対して責任を負います。提供されるコンテンツは、他のユーザーと共有して差し支えのないコンテンツに限定してください。"
                        "本サービスを介して投稿されたまたは本サービスを通じて取得したコンテンツなどの使用またはこれらへの依拠は、ユーザーの自己責任において行ってください。"
                        "当社は、本サービスを介して投稿されたいかなるコンテンツや通信内容についても、その完全性、真実性、正確性、もしくは信頼性を是認、支持、表明もしくは保証せず、また本サービスを介して表示されるいかなる意見についても、それらを是認するものではありません。"
                        "利用者は、本サービスの利用により、不快、有害、不正確あるいは不適切なコンテンツ、場合によっては、不当表示されている投稿またはその他欺瞞的な投稿に接する可能性があることを、理解しているものとします。"
                        "すべてのコンテンツは、その作成者が単独で責任を負うものとします。当社は、本サービスを介して投稿されるコンテンツを監視または管理することはできず、また、そのようなコンテンツについて責任を負うこともできません。"
                        "当社は、ユーザー契約に違反しているコンテンツ（著作権もしくは商標の侵害その他の知的財産の不正利用、詐欺、なりすまし、不法行為または嫌がらせ等）を削除する権利を留保します。"
                        "違反を報告または上申するための特定のポリシーおよびプロセスに関する情報は、本サービスのセーフティルールを参照してください。"
                        "ご自身のコンテンツが著作権を侵害されたと判断される場合は、違反報告をしていただくか、サポートセンターまで報告をお願いします。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "ユーザーの権利およびコンテンツに対する権利の許諾",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "ユーザーは、本サービス上にまたは本サービスを介して自ら送信または表示するコンテンツに対する権利を留保するものとします。ユーザーのコンテンツの所有権はユーザーにあります。"
                        "ユーザーは、本サービス上にまたは本サービスを介してコンテンツを送信または表示することによって、当社が、既知のものか今後開発されるものかを問わず、あらゆる媒体を介してのコンテンツを使用、コピー、複製、処理、改変、修正、公表、送信、表示するための、非独占的ライセンスを当社に対し無償で許諾することになります。"
                        "このライセンスによって、ユーザーは、当社や他のユーザーに対し、ご自身のを国内の他のユーザーからの閲覧を可能とすることを承認することになります。"
                        "ユーザーは、このライセンスには、Yoloが、コンテンツ利用に関する当社の条件に従うことを前提に、本サービスを提供、宣伝および向上させるための権利ならびに本サービスに対しまたは本サービスを介して送信されたコンテンツを他の媒体やサービスで配給、放送、配信、プロモーションまたは公表することを目的として、その他の企業、組織または個人に提供する権利が含まれていることに同意するものとします。"
                        "ユーザーは、Yoloがユーザーのコンテンツを投稿や表示をする際にコンテンツが修正または変更される可能性があること、およびコンテンツを異なるメディアに適合させるためにコンテンツに変更を加える可能性があることを理解しているものとします。"
                        "ユーザーは、ご自身が本サービス上でまたは本サービスを通じて送信または表示するコンテンツに関して、本規約で付与される権利を許諾するために必要な、すべての権利、ライセンス、同意、許可、権能および権限を有していることを表明し保証するものとします。"
                        "ユーザーは、ご自身が必要な許可を得ているまたはその他の理由により素材を投稿しYoloに上記のライセンスを許諾することができる法的権限を有している場合を除き、当該コンテンツが著作権その他の財産権の対象となる素材を含むものではないことに同意するものとします。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "本サービスの改善と終了",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Yoloは、サービスの向上を目指し、より便利なSNSアプリに改善していく上で、機能の追加や変更、削除をすることがあります。"
                        "ユーザーの権利や義務に重要な影響がないものに対しては事前通知を行わないことがあります。また、場合によっては本サービスを全面的に停止することもあります。"
                        "その場合、その旨を事前告知します。いかなる状況でもユーザーはアカウントを削除できます。"
                        "ただし、$platformOSプラットフォームなどのサードパーティーが運営している支払いアカウントを使用している場合は、そのプラットフォームを経由してアプリ内購入の管理を行ってください。"
                        "ユーザーが本規約に違反している場合、通知することなくユーザーのアカウントを削除することがあります。その場合、アプリ内購入に対しての払い戻しを受ける権利は消滅します。",
                        style: const TextStyle(
                          locale: Locale("ja", "JP"),
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "ユーザーに付与する権利",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "本サービスへのアクセスおよび利用に関し、個人的で、国内で利用可能な、著作権使用料無料、譲渡不可能、非独占的、取消し可能、サブライセンス権なしのライセンスをお客様に付与します。"
                        "このライセンスは、Yoloが意図して規約で許可した当サービスの利点をお客様に利用、享受していただくことのみを目的としています。"
                        "したがってお客様は以下の行為を行わないことに合意します：",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "・本サービスに含まれるすべてのコンテンツの商業目的での利用",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・いかなる著作権のある題材、画像、商標、商品名、サービスマーク、その他の知的財産やコンテンツもしくは占有情報の複写、修正、転送、その派生作品の作成、それらの利用または複製。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・すべてのロボット、ボット、スパイダー、クローラー、スクレイパー、サイト検索アプリ、プロキシ、または、本サービスやそのコンテンツのナビゲーション構造もしくは表示にアクセス、検索、索引付け、「データマインニング」もしくは何らかの複製や回避を行うためのその他手動か自動のデバイス、手法もしくはプロセス",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・本サービスまたは本サービスに接続するサーバーやネットワークを妨害、または悪影響をもたらす可能性のある方法での当サービスの利用。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・ウィルスやその他悪質なコードのアップロードまたは別の方法で本サービスのセキュリティを脅かす行為。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・何らかの目的で人を別のウェブサイトに誘導するためのサービスへの参照を含む別のデバイスの利用。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・弊社よる合意なく、本サービスまたは他のメンバーのコンテンツや情報と交流する第三者アプリケーションの利用や開発。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・弊社よる合意のない、アプリケーションのプログラミングインターフェースの使用、アクセスまたは公開。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・本サービスまたはシステムやネットワークの脆弱性の調査、精査または試験。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・本規約の違反に当たる行為の奨励または促進。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                        ],
                      ),
                      Text(
                        "本サービスの不法または不正利用およびその双方に対応して、お客様のアカウント停止を含めあらゆる可能な法的措置を調査し講じる場合があります。"
                        "Yoloがお客様に提供するすべてのソフトウェアは、アップグレード、アップデートまたはその他新機能を自動的にダウンロードしインストールします。これら自動ダウンロードの設定は、ご自身のデバイスの設定画面から調整できます。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "ユーザーがYoloに\n付与する権利",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "アカウントを作成することにより、ユーザーが本サービス上でもしくは他のメンバーへの転送時に投稿、アップロード、表示もしくは入手可能にする情報について、ユーザーは以下をYoloに認めるものとします。"
                        "全地域を対象とし、移転可能、サブライセンス可能、ロイヤルティフリー、所有、保存、使用、コピー、表示、複製、翻案、編集、発行、変更、配布する権利およびライセンス。"
                        "お客様のコンテンツに関するYoloのライセンスは非独占的とします。"
                        "ただし弊社サービスの利用において作成された派生的作品についてはYoloが独占的なライセンスを所有します。"
                        "例えば弊社サービスのスクリーンショットにお客様のコンテンツが写り込んでいる場合は、Yoloが独占的ライセンスを所有します。"
                        "さらに他メンバーもしくは第三者がユーザーコンテンツを本サービスから流用し不当に使用する場合、ユーザーのコンテンツがYolo外で利用されることを防ぐため、弊社がお客様に代わって行動することをお客様は弊社に認めるものとします。"
                        "ユーザーコンテンツについて本サービス外で第三者が流用および使用する場合、ユーザーに代わって当局へ通知すること（ただし義務ではない）を明示的に含みます。"
                        "ユーザーコンテンツに関するYoloのライセンス認可は、適用法（コンテンツがこれらの法律で定義されている個人情報を含む範囲で、個人情報保護関連法など）の下で認められるお客様の権利に従うものとします。"
                        "またライセンス認可の目的は本サービスの運営、開発、提供、および改善、さらに新サービスの研究開発に限定されます。ユーザーが発信するコンテンツ、またはユーザーが弊社に対しサービスで発信することを承認するコンテンツは他のメンバーが閲覧したり、サービスを訪問もしくは参加する人物が閲覧する可能性があることについて、ユーザーは同意するものとします。"
                        "アカウント作成時に提出したすべての情報が正確かつ真実であり、ユーザーには本サービスにコンテンツを投稿する権利があり、上述の通りYoloに対しライセンスを付与することにユーザーは合意します。"
                        "本サービスの一環として、弊社がユーザーの公開したコンテンツを監視または審査する場合があることを理解し合意します。Yoloは独自の判断で、本規約に違反する、または本サービスの評判を害するコンテンツの一部または全部を削除することがあります。"
                        "弊社のサポートセンターとのやり取りの際は、ユーザーは礼儀をわきまえ丁寧に応対することに合意します。ユーザーの態度が常に脅迫的か攻撃的であると感じた場合、Yoloはお客様のアカウントを即時解約する権利を留保します。"
                        "Yoloがユーザーに本サービスの利用を許可する対価として、弊社および第三者パートナーが本サービスに広告を掲載できることにユーザーは合意します。"
                        "本サービスに関する提案やフィードバックをYoloに提出することにより、弊社がユーザーに報酬を支払わず、あらゆる目的でこれらフィードバックを利用し共有する場合があることにユーザーは合意します。"
                        "法律で求められる場合や、ユーザーとの合意の遂行のため、もしくは当該アクセス、保管または開示によって以下に掲げる目的等の正当な利益を実現すると誠実に信じる場合、Yoloはアカウント情報やコンテンツへのアクセス、保管または開示を行うことがあることをご承知おきください"
                        ":(i) 法的手続きの遵守、(ii) 規約の実行、(iii) コンテンツが第三者の権利を侵害するとの申立てへの対応、(iv) 顧客サービスに関してお客様の依頼への対応、または、(v) 当社もしくはその他の者の権利、財産または個人的な安全性の保護。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "コミュニティガイドライン",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "本サービスを利用するユーザーは、以下の事項を行わないことを合意します。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "・不法または本規約で禁じられた目的のための当サービスの利用。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・Yoloに損害を与えるようなサービスの使用",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・コミュニティ ガイドラインの違反",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・他のユーザーに対するスパムメールの送信、金銭の懇請または詐欺。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・なりすまし行為、または許可のない他者の画像の投稿。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・他人に対するいじめ、ストーカー行為、暴力、ハラスメント、虐待または中傷。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・個人の権利に違反または侵害するコンテンツの投稿（肖像権、プライバシー権、著作権、商標権またはその他知的財産権や契約上の権利を含む）。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・暴力を扇動するコンテンツ、またはヌードやどぎつい不要な暴力を含むコンテンツの投稿。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・商業や不法な目的での個人識別情報の要求、または許可なく他者の個人情報を流布すること。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                          Text(
                            "・他のアカウントの利用、他のアカウント共有、もしくは複数のアカウントの保持。",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: ThemeColor.text),
                          ),
                        ],
                      ),
                      Text(
                        "ユーザーが本サービスを誤用した場合やYoloが不適切または不法と見なす行動をとった場合、Yoloは購入代金を返金せず、ユーザーのアカウントを調査または解約する権利を留保します。"
                        "このような行為またはコミュニケーションについては、本サービスの利用外で発生した場合であっても本サービスを通じて出会ったユーザーが関与する限り適用するものとします。",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: ThemeColor.text),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(termOfUseProvider.notifier).state = true;

                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColor.text,
                        side: const BorderSide(
                          color: ThemeColor.text,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "同意する",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: ThemeColor.text),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 40 + 120,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "登録",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: ThemeColor.headline,
                        ),
                  ),
                  const Gap(24),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: ThemeColor.stroke,
                        ),
                        child: TextFormField(
                          cursorColor: ThemeColor.highlight,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (text) {
                            ref.read(emailInputTextProvider.notifier).state =
                                text;
                          },
                          style: const TextStyle(
                            color: ThemeColor.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            hintStyle: TextStyle(
                              color: ThemeColor.highlight,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            hintText: "email",
                          ),
                        ),
                      ),
                      //email
                      ref.watch(errorTextProvider).length > 5 &&
                              ref.watch(errorTextProvider).substring(0, 5) ==
                                  "email"
                          ? Text(
                              "不正なメールアドレスです。",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(color: ThemeColor.error),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 30,
                      ),
                      //password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: ThemeColor.stroke,
                        ),
                        child: TextFormField(
                          cursorColor: ThemeColor.highlight,
                          onChanged: (text) {
                            ref.read(passwordInputTextProvider.notifier).state =
                                text;
                          },
                          obscureText: !ref.watch(passwordVisibleProvider),
                          style: const TextStyle(
                            color: ThemeColor.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            hintStyle: const TextStyle(
                              color: ThemeColor.highlight,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            hintText: "password",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable

                                  ref
                                          .read(passwordVisibleProvider.notifier)
                                          .state =
                                      !ref.read(passwordVisibleProvider);
                                },
                                child: Icon(
                                  // Based on passwordVisible state choose the icon
                                  ref.watch(passwordVisibleProvider)
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: ThemeColor.icon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ref.watch(errorTextProvider).length > 8 &&
                              ref.watch(errorTextProvider).substring(0, 8) ==
                                  "password"
                          ? Text(
                              "パスワードが短すぎます",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(color: ThemeColor.error),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: ThemeColor.button,
                        checkColor: ThemeColor.background,
                        value: ref.watch(termOfUseProvider),
                        side: const BorderSide(
                          color: ThemeColor.button,
                        ),
                        onChanged: (val) {
                          ref.read(termOfUseProvider.notifier).state = val!;
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          showPolicyDialog(context, ref);
                        },
                        child: const Text(
                          "利用規約",
                          style: TextStyle(
                            color: ThemeColor.highlight,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                            decorationColor: ThemeColor.text,
                            fontFamily: "Noto Sans JP",
                          ),
                        ),
                      ),
                      Text(
                        "に同意します",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ThemeColor.highlight,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Material(
                    color: ThemeColor.highlight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        primaryFocus?.unfocus();
                        if (ref.read(termOfUseProvider)) {
                          final status =
                              await ref.watch(authNotifierProvider).signUp();
                          ref.read(errorTextProvider.notifier).state = status;
                          ref.read(signupProcessProvider.notifier).state =
                              false;
                          if (status == "success") {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        } else {
                          showMessage('利用規約に同意してください。');
                        }
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "登録する",
                          style: TextStyle(
                            color: ThemeColor.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "既にアカウントをお持ちの方は ",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ThemeColor.highlight,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                              settings: const RouteSettings(name: "sign_in"),
                            ),
                          );
                        },
                        child: const Text(
                          "こちらへ",
                          style: TextStyle(
                            color: ThemeColor.highlight,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: ThemeColor.text,
                            decorationThickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: ref.watch(signupProcessProvider) ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Visibility(
                visible: ref.watch(signupProcessProvider),
                child: ShaderWidget(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "サインアップ中",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(12),
                        CircularProgressIndicator(
                          strokeWidth: 1.2,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
