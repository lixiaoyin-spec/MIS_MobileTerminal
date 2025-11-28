import request from './request'

export function uploadResource(data) {
  return request({
    url: '/api/resource/upload',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
