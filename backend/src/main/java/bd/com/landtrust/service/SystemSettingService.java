package bd.com.landtrust.service;

import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.repository.SystemSettingRepository;
import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicReference;

@Service
public class SystemSettingService {

    private final SystemSettingRepository settingRepository;
    private final AtomicReference<SystemSettingEntity> cachedSettings = new AtomicReference<>();
    private volatile long lastFetchTime = 0;
    private static final long CACHE_TTL_MS = 60_000;

    public SystemSettingService(SystemSettingRepository settingRepository) {
        this.settingRepository = settingRepository;
    }

    public SystemSettingEntity getSettings() {
        long now = System.currentTimeMillis();
        SystemSettingEntity cached = cachedSettings.get();
        if (cached != null && (now - lastFetchTime) < CACHE_TTL_MS) {
            return cached;
        }

        SystemSettingEntity fresh = settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });

        cachedSettings.set(fresh);
        lastFetchTime = now;
        return fresh;
    }

    public SystemSettingEntity saveSettings(SystemSettingEntity updated) {
        SystemSettingEntity saved = settingRepository.save(updated);
        cachedSettings.set(saved);
        lastFetchTime = System.currentTimeMillis();
        return saved;
    }

    public void invalidateCache() {
        cachedSettings.set(null);
        lastFetchTime = 0;
    }
}
