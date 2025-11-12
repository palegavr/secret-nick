import {
  Component,
  computed,
  ElementRef,
  HostBinding,
  inject,
  input,
} from '@angular/core';
import { tap } from 'rxjs';

import { IconButton } from '../icon-button/icon-button';
import {
  AriaLabel,
  IconName,
  MessageType,
  NavigationLinkSegment,
  PersonalLink,
  PopupPosition,
} from '../../../app.enum';
import { PopupService } from '../../../core/services/popup';
import { copyToClipboard } from '../../../utils/copy';
import { UrlService } from '../../../core/services/url';
import { ParticipantInfoModal } from '../../../room/components/participant-info-modal/participant-info-modal';
import { ModalService } from '../../../core/services/modal';
import { getPersonalInfo } from '../../../utils/get-personal-info';
import { UserService } from '../../../room/services/user';
import type { User } from '../../../app.models';
import { ParticipantDeleteModal } from './components/delete-participant-modal/participant-delete-modal';

@Component({
  selector: 'li[app-participant-card]',
  imports: [IconButton],
  templateUrl: './participant-card.html',
  styleUrl: './participant-card.scss',
})
export class ParticipantCard {
  readonly participant = input.required<User>();
  readonly isCurrentUserAdmin = input.required<boolean>();
  readonly isRoomClosed = input<boolean>(false);

  readonly showCopyIcon = input<boolean>(false);
  readonly userCode = input<string>('');
  readonly showInfoIcon = input<boolean>(false);

  readonly #popup = inject(PopupService);
  readonly #urlService = inject(UrlService);
  readonly #host = inject(ElementRef<HTMLElement>);
  readonly #modalService = inject(ModalService);
  readonly #userService = inject(UserService);

  public readonly isCurrentUser = computed(() => {
    const code = this.userCode();
    return !!code && this.participant()?.userCode === code;
  });
  public readonly fullName = computed(
    () => `${this.participant().firstName} ${this.participant().lastName}`
  );

  public readonly iconCopy = IconName.Link;
  public readonly ariaLabelCopy = AriaLabel.ParticipantLink;
  public readonly iconInfo = IconName.Info;
  public readonly ariaLabelInfo = AriaLabel.Info;
  public readonly iconDelete = IconName.Delete;
  public readonly ariaLabelDelete = AriaLabel.Delete;

  @HostBinding('tabindex') tab = 0;
  @HostBinding('class.list-row') rowClass = true;

  public async copyRoomLink(): Promise<void> {
    const host = this.#host.nativeElement;
    const code = this.participant().userCode;

    if (!code) {
      this.#popup.show(
        host,
        PopupPosition.Right,
        { message: PersonalLink.Error, type: MessageType.Error },
        false
      );

      return;
    }

    const { absoluteUrl } = this.#urlService.getNavigationLinks(
      code,
      NavigationLinkSegment.Room
    );
    const ok = await copyToClipboard(absoluteUrl);

    this.#popup.show(
      host,
      PopupPosition.Right,
      {
        message: ok ? PersonalLink.Success : PersonalLink.Error,
        type: ok ? MessageType.Success : MessageType.Error,
      },
      false
    );
  }

  public onInfoClick(): void {
    if (!this.participant().isAdmin) {
      this.#openModal();

      return;
    }

    this.#showPopup();
  }

  public onDeleteClick(): void {
    this.#modalService.openWithResult(
      ParticipantDeleteModal,
      {
        participantFullName: `${this.participant().firstName} ${this.participant().lastName}`
      },
      {
        buttonAction: () => {
          this.#modalService.close();
          this.#userService.deleteUser(this.participant().id).subscribe();
        },
        closeModal: () => this.#modalService.close(),
        cancelButtonAction: () => this.#modalService.close(),
      }
    );
  }

  public onCopyHover(target: EventTarget | null): void {
    if (target instanceof HTMLElement) {
      this.#popup.show(
        target,
        PopupPosition.Center,
        { message: PersonalLink.Info, type: MessageType.Info },
        true
      );
    }
  }

  public onCopyLeave(target: EventTarget | null): void {
    if (target instanceof HTMLElement) {
      this.#popup.hide(target);
    }
  }

  #openModal(): void {
    const personalInfo = getPersonalInfo(this.participant());
    const roomLink = this.#urlService.getNavigationLinks(
      this.participant().userCode || '',
      NavigationLinkSegment.Join
    ).absoluteUrl;

    this.#userService
      .getUsers()
      .pipe(
        tap(({ status }) => {
          if (status === 200) {
            this.#modalService.openWithResult(
              ParticipantInfoModal,
              { personalInfo, roomLink },
              {
                buttonAction: () => this.#modalService.close(),
                closeModal: () => this.#modalService.close(),
              }
            );
          }
        })
      )
      .subscribe();
  }

  #showPopup(): void {
    const { email, phone } = this.participant();
    const container = this.#host.nativeElement.closest(
      'app-participant-list'
    ) as HTMLElement;
    const message = email
      ? `${phone}
         ${email}`
      : `${phone}`;

    this.#popup.show(
      container,
      PopupPosition.Right,
      {
        message,
        type: MessageType.Info,
      },
      true
    );
  }
}
