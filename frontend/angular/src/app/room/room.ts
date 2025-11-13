import {
  Component,
  computed,
  ElementRef,
  inject,
  OnInit,
  signal,
  viewChild,
} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { tap } from 'rxjs';

import { RoomInfo } from './components/room-info/room-info';
import { RoomService } from './services/room';
import { UserService } from './services/user';
import { ParticipantList } from '../shared/components/participant-list/participant-list';
import { RandomizeCard } from './components/randomize-card/randomize-card';
import { GifteeInfo } from './components/giftee-info/giftee-info';
import {
  CONFETTI_ANIMATION_PATH,
  DEFAULT_ROOM_NAME,
  MIN_USERS_NUMBER,
} from '../app.constants';
import { MyWishlist } from './components/my-wishlist/my-wishlist';
import { ModalService } from '../core/services/modal';
import { GifteeInfoModal } from './components/giftee-info-modal/giftee-info-modal';
import { getPersonalInfo } from '../utils/get-personal-info';
import { MyWishlistModal } from './components/my-wishlist/components/my-wishlist-modal/my-wishlist-modal';
import { LottieAnimationService } from '../core/services/lottie-animation';
import { PersonalInfoCard } from './components/personal-info-card/personal-info-card';
import { UrlService } from '../core/services/url';
import { NavigationLinkSegment } from '../app.enum';
import { PersonalInfoModal } from './components/personal-info-modal/personal-info-modal';
import { InvitationModal } from '../shared/components/invitation-modal/invitation-modal';
import {User} from '../app.models';

@Component({
  selector: 'app-room',
  imports: [
    RoomInfo,
    RandomizeCard,
    GifteeInfo,
    ParticipantList,
    MyWishlist,
    PersonalInfoCard,
  ],
  templateUrl: './room.html',
  styleUrl: './room.scss',
})
export class Room implements OnInit {
  public readonly lottieContainer =
    viewChild.required<ElementRef>('lottieContainer');

  readonly #route = inject(ActivatedRoute);
  readonly #roomService = inject(RoomService);
  readonly #userService = inject(UserService);
  readonly #modalService = inject(ModalService);
  readonly #lottieAnimationService = inject(LottieAnimationService);
  readonly #urlService = inject(UrlService);

  public readonly roomData = this.#roomService.roomData;
  public readonly users = this.#userService.users;
  public readonly isAdmin = this.#userService.isAdmin;
  public readonly invitationLink = this.#roomService.invitationLink;
  public readonly isRoomDrawn = this.#roomService.isRoomDrawn;
  public readonly currentUser = this.#userService.currentUser;
  public readonly userCode = this.#userService.userCode;
  public readonly isRoomClosed = computed(() => this.roomData().closedOn != null);

  public readonly isBackgroundAnimationActive = signal<boolean>(false);

  public readonly isRandomizeCardDisabled = computed(
    () => this.users().length < MIN_USERS_NUMBER
  );
  public readonly gifteeName = computed(() => this.#getGifteeName());
  public readonly giftee = computed(() => this.#getGiftee());
  public readonly firstName = computed(
    () => this.currentUser()?.firstName ?? 'Participant'
  );
  public readonly roomName = computed(
    () => this.roomData()?.name || DEFAULT_ROOM_NAME
  );

  public readonly userLink = computed(() =>
    this.roomData().modifiedOn
      ? this.#urlService.getNavigationLinks(
          this.userCode(),
          NavigationLinkSegment.Room
        ).absoluteUrl
      : ''
  );

  ngOnInit(): void {
    this.#route.paramMap.subscribe((params) => {
      this.#userService.setUserCode(params.get('userCode') ?? '');
    });

    this.#roomService.getRoomByUserCode(this.#userService.userCode());
    this.#userService.getUsers().subscribe();
  }

  public onDrawNames(): void {
    this.#userService
      .drawNames()
      .pipe(
        tap(({ status }) => {
          if (status === 200) {
            this.#toggleBackgroundAnimation();
            this.#lottieAnimationService.play({
              container: this.lottieContainer().nativeElement,
              path: CONFETTI_ANIMATION_PATH,
              onComplete: () => this.#toggleBackgroundAnimation(),
            });
          }
        })
      )
      .subscribe();
  }

  public onReadDetails(): void {
    this.#modalService.openWithResult(
      GifteeInfoModal,
      {
        personalInfo: getPersonalInfo(this.giftee()),
        wishListInfo: {
          interests: this.giftee().interests || '',
          wishList: this.giftee().wishList || [],
        },
      },
      {
        buttonAction: () => this.#modalService.close(),
        closeModal: () => this.#modalService.close(),
      }
    );
  }

  public onViewWishlist(): void {
    this.#modalService.openWithResult(
      MyWishlistModal,
      {
        wishListInfo: {
          interests: this.currentUser()?.interests || '',
          wishList: this.currentUser()?.wishList || [],
        },
        budget: this.roomData().giftMaximumBudget,
      },
      {
        buttonAction: () => this.#modalService.close(),
        closeModal: () => this.#modalService.close(),
      }
    );
  }

  public onViewInformation(): void {
    this.#modalService.openWithResult(
      PersonalInfoModal,
      {
        personalInfo: getPersonalInfo(this.currentUser()),
      },
      {
        buttonAction: () => this.#modalService.close(),
        closeModal: () => this.#modalService.close(),
      }
    );
  }

  public openInvitationModal(): void {
    const refreshAndClose = () => {
      this.#roomService.getRoomByUserCode(this.userCode());
      this.#modalService.close();
    };

    this.#modalService.openWithResult(
      InvitationModal,
      {
        roomLink: this.invitationLink(),
        invitationNote: this.roomData()?.invitationNote,
        userCode: this.userCode(),
      },
      {
        buttonAction: refreshAndClose,
        closeModal: refreshAndClose,
      }
    );
  }

  #getGifteeName(): string {
    const gifteeUser: User = this.#getGiftee();
    const [firstName, lastName] = [gifteeUser.firstName, gifteeUser.lastName];

    return firstName && lastName ? `${firstName} ${lastName}` : '';

  }

  #getGiftee(): User {
    const gifteeId = this.#userService.currentUser()?.giftToUserId || 0;
    const gifteeUser = this.users().find((user) => user.id === gifteeId)!;
    return gifteeUser;
  }

  #toggleBackgroundAnimation(): void {
    this.isBackgroundAnimationActive.update((prev) => !prev);
  }
}
