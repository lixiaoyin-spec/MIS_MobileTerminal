import request from './request'

export function getRecommendPartners(token) {
  return request({
    url: '/api/partner/recommend',
    method: 'get',
    params: { token }
  })
}
