import {Component, input, output} from '@angular/core';
import {CommonModalTemplate} from '../../../modal/common-modal-template/common-modal-template';
import {ButtonText, ModalTitle, PictureName} from '../../../../../app.enum';

@Component({
  selector: 'app-participant-delete-modal',
  imports: [CommonModalTemplate],
  templateUrl: './participant-delete-modal.html',
  styleUrl: './participant-delete-modal.scss'
})
export class ParticipantDeleteModal {
  readonly participantFullName = input.required<string>();

  readonly closeModal = output<void>();
  readonly buttonAction = output<void>();
  readonly cancelButtonAction = output<void>();

  public readonly picName = PictureName.ActionCardBg;
  public readonly title = ModalTitle.DeleteParticipant;
  public readonly confirmButtonText = ButtonText.Confirm;
  public readonly cancelButtonText = ButtonText.Cancel;
  public readonly subtitle = '';

  public onCloseModal(): void {
    this.closeModal.emit();
  }

  public onButtonClick(): void {
    this.buttonAction.emit();
  }

  public onCancelButtonClick() {
    this.cancelButtonAction.emit();
  }
}
