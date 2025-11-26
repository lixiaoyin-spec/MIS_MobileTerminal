package com.example.springbootapp.serviceImpl;

import com.example.springbootapp.po.ResourcePO;
import com.example.springbootapp.po.User;
import com.example.springbootapp.repository.ResourceRepository;
import com.example.springbootapp.repository.UserRepository;
import com.example.springbootapp.service.ResourceService;
import com.example.springbootapp.vo.ResourceVO;
import jakarta.annotation.Resource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class ResourceServiceImpl implements ResourceService {

    // 从配置文件读取上传路径和访问前缀
    @Value("${file.upload.path}")
    private String uploadPath;
    @Value("${file.access.prefix}")
    private String accessPrefix;

    @Resource
    private ResourceRepository resourceRepository;
    @Resource
    private UserRepository userRepository;

    @Override
    public ResourceVO upload(MultipartFile file, String token) {
        // 1. 解析token获取用户ID
        Assert.isTrue(token.contains("_") && token.split("_").length >= 3, "无效token");
        Long userId = Long.parseLong(token.split("_")[2]);

        // 2. 校验用户存在
        User user = userRepository.selectById(userId);
        Assert.notNull(user, "用户不存在");

        // 3. 校验文件不为空
        Assert.notNull(file, "请选择文件");
        Assert.isTrue(!file.isEmpty(), "文件内容不能为空");

        // 4. 处理文件：生成唯一文件名（避免重名）
        String originalFilename = file.getOriginalFilename();
        String fileSuffix = StringUtils.getFilenameExtension(originalFilename); // 提取后缀
        String uniqueFilename = UUID.randomUUID().toString() + "." + fileSuffix; // 唯一文件名

        // 5. 确保上传目录存在
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); // 递归创建目录
        }

        // 6. 保存文件到服务器
        File destFile = new File(uploadPath + File.separator + uniqueFilename);
        try {
            file.transferTo(destFile); // 写入文件
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败：" + e.getMessage());
        }

        // 7. 构建文件访问URL
        String fileUrl = accessPrefix + "/" + uniqueFilename;

        // 8. 保存文件信息到数据库
        ResourcePO resource = new ResourcePO();
        resource.setUserId(userId);
        resource.setFilename(originalFilename);
        resource.setFileSuffix(fileSuffix);
        resource.setFilePath(destFile.getAbsolutePath());
        resource.setFileUrl(fileUrl);
        resource.setFileSize(file.getSize());
        resource.setCreateTime(LocalDateTime.now());
        resourceRepository.insert(resource);

        // 9. 返回文件URL
        ResourceVO result = new ResourceVO();
        result.setFileUrl(fileUrl);
        return result;
    }
}