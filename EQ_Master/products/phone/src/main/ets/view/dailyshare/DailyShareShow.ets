import { PictureItem } from '../../viewmodel/PictureItem';
import { initializePictures,initializePicture } from '../../viewmodel/PictureViewModel';
import { PictureType } from '../../common/constants/PictureConstants';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { PictureView } from './PictureView';
import { DailyShare } from '../../server/dailyshare/DailyShareData';
import { Router } from '@ohos.arkui.UIContext';
import { router } from '@kit.ArkUI';
import Logger from '../../common/utils/Logger';
import { preferences } from '@kit.ArkData';
import PreferenceModel from '../../model/PreferenceModel';
import DailyShareServer from '../../server/dailyshare/DailyShareServer';
import ResponseResult from '../../server/ResponseResult';
import PromptUtil from '../../common/utils/PromptUtil';
import { DailyShareItem } from '../../common/constants/DailyShareList';

@Extend(Text)
function textStyle(fontSize: number, fontWeight: number) {
  .fontSize(fontSize)
  .fontWeight(fontWeight)
  .fontColor($r('app.color.font_black'))
}
@Entry
@Component
export struct DailyShareShow {
  @State photos: Array<PictureItem> = [];
  @State sortName: Resource = $r('app.string.recently');
  private initType: string = '';
  @State initDailyShare: Array<DailyShare> = []; //接受到后端数据后会更新， 重新调用build()

  aboutToAppear() {
    this.getInitDailyShareList(this.initType, 1,4,false) // false获取最新的DailyShare

    if (PictureType.QUESTION === this.initType) {
      this.sortName = $r('app.string.question');
    } else if (PictureType.TIP === this.initType) {
      this.sortName = $r('app.string.tip');
    } else if (PictureType.STORY === this.initType) {
      this.sortName = $r('app.string.story');
    }
  }

  getInitDailyShareList(type: string, page: number, pageSize: number, orderByPopularity: boolean){
    Logger.info(CommonConstants.DAILY_SHARE_TYPE_PAGE_TAG,
      'getDailyShare page: ' + page + ' pageSize: ' + pageSize + ' type: ' + type + ' orderByPopularity: ' +
        orderByPopularity);
    DailyShareServer.getDailyShareTypeList(type, page, pageSize, orderByPopularity).then((data: Array<DailyShare>) => {
      this.initDailyShare = data;
    }).catch((err: Resource | ResponseResult) => {
      if (err instanceof ResponseResult) {
        if (err.message !== null) {
          PromptUtil.promptMessage(err.message, CommonConstants.PROMPT_DURATION);
        }
      } else {
        PromptUtil.promptMessage(err, CommonConstants.PROMPT_DURATION);
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text(this.sortName)
          .width(CommonConstants.WIDTH_SORT_NAME)
          .textStyle(CommonConstants.FONT_SIZE_SORT_TITLE, CommonConstants.FONT_WEIGHT_NORMAL)
        // Text(this.getDailyShare('question-1').context)
        Text($r('app.string.more'))
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
          .textAlign(TextAlign.End)
          .textStyle(CommonConstants.FONT_SIZE_PHOTO_NAME, CommonConstants.FONT_WEIGHT_LIGHT)
          .lineHeight(CommonConstants.LINE_HEIGHT_MORE)
          .opacity($r('app.float.opacity_light'))
          .fontColor($r('app.color.start_window_background'))
          .onClick(() => {
            PreferenceModel.putPreference('dailyShareType', this.initType);

            router.pushUrl({
              // 转到dailysharetypeshow
              url: CommonConstants.DAILY_SHARE_TYPE_PAGE_URL
            }).catch((error: Error) => {
              Logger.error(CommonConstants.DAILY_SHARE_TYPE_PAGE_TAG, 'DailyShareShowPage pushUrl error ' + JSON.stringify(error));
            }).then(()=> { //成功跳转信息
              Logger.info(CommonConstants.DAILY_SHARE_TYPE_PAGE_TAG, 'DailyShareShowPage pushUrl success')
            })
          })
      }
      .width(CommonConstants.WIDTH_SORT)
      .margin({ top: CommonConstants.MARGIN_TOP_SORT, bottom: CommonConstants.MARGIN_BOTTOM_SORT })

      Grid() {
        ForEach(initializePictures(this.initType,this.initDailyShare), (item: PictureItem) => {
          GridItem() {
            PictureView({photos: item})
              .onClick(() => {
                PreferenceModel.putPreference('dailyShareId', item.id);
                router.pushUrl({
                  url: CommonConstants.DAILY_SHARE_DETAIL_PAGE_URL,
                  // params: item.id
                }).catch((error: Error) => {
                  Logger.error(CommonConstants.DAILY_SHARE_DETAIL_PAGE_TAG,
                    'DailyShareShowPage pushUrl error ' + JSON.stringify(error));
                }).then(()=> { //成功跳转信息
                  Logger.info(CommonConstants.DAILY_SHARE_TYPE_PAGE_TAG, 'DailyShareShowPage pushUrl success')
                })
              })
          }

        }, (item: PictureItem) => JSON.stringify(item))
      }
      .columnsTemplate(CommonConstants.TWO_COLUMNS)
      .rowsTemplate(CommonConstants.TWO_ROWS)
      .columnsGap(CommonConstants.GAP_COLUMNS)
      .rowsGap(CommonConstants.GAP_COLUMNS)
      .width(CommonConstants.PAGE_WIDTH)
      .height(CommonConstants.HEIGHT_GRID)
      .margin({ bottom: CommonConstants.MARGIN_BOTTOM_GRID })
    }
  }
}