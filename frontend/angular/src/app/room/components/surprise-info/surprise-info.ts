import {Component, inject, input, signal} from '@angular/core';
import {AiService} from '../../../ai/services/ai';
import {Button} from '../../../shared/components/button/button';

@Component({
  selector: 'app-surprise-info',
  templateUrl: './surprise-info.html',
  styleUrl: './surprise-info.scss',
  imports: [Button],
})
export class SurpriseInfo {
  readonly #aiService = inject(AiService);

  readonly text = input.required<string>();
  readonly withAiHelp = input<boolean>(false);

  readonly proposalsGeneratedByAI = signal<{
    loading: boolean;
    content: string;
  }>({
    loading: false,
    content: '',
  });

  generateProposals(): void {
    this.proposalsGeneratedByAI.update(prev =>
      ({
        ...prev,
        loading: true,
      }));

    const handleError = () => {
      this.proposalsGeneratedByAI.update(prev =>
        ({
          ...prev,
          loading: false,
        }));
      }

    this.#aiService.generateIdeasForGift(this.text())
      .subscribe({
        next: response => {
          if (response.status === 200) {
            this.proposalsGeneratedByAI.set({loading: false, content: response.body!.ideasForGift});
          } else {
            handleError();
          }
        },
        error: () => {
          handleError();
        }
      });
  }
}
