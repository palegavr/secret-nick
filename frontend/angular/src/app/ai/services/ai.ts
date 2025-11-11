import {inject, Injectable} from '@angular/core';
import {ApiService} from '../../core/services/api';
import {Observable} from 'rxjs';
import {HttpResponse} from '@angular/common/http';
import {IdeasForGift} from '../../app.models';

@Injectable({
  providedIn: 'root',
})
export class AiService {
  readonly #apiService = inject(ApiService);

  public generateIdeasForGift(
    interests: string,
  ): Observable<HttpResponse<IdeasForGift>> {
    return this.#apiService.generateIdeasForGift(interests);
  }
}
