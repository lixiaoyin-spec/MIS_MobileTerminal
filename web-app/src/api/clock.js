import request from './request'

export function addClock(data) {
  return request({
    url: '/api/clock/add',
    method: 'post',
    data
  })
}

export function getClockList(token) {
  return request({
    url: '/api/clock/list',
    method: 'get',
    params: { token }
  })
}
