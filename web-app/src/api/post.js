import request from './request'

export function getPostList() {
  return request({
    url: '/api/post/list',
    method: 'get'
  })
}

export function createPost(data) {
  return request({
    url: '/api/post/create',
    method: 'post',
    data
  })
}

export function getPostDetail(postId) {
  return request({
    url: '/api/post/detail',
    method: 'get',
    params: { postId }
  })
}

export function addComment(data) {
  return request({
    url: '/api/comment/add',
    method: 'post',
    data
  })
}
