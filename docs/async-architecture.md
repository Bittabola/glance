# Glance Async Architecture Refactor

## Core Principles

1. **Non-blocking Widget Loading**: No widget should block another
2. **Priority-based Rendering**: Critical widgets load first
3. **Progressive Enhancement**: Show content as soon as available
4. **Graceful Degradation**: Failed widgets don't break the page
5. **Real-time Updates**: Use WebSocket/SSE for live updates

## Component Architecture

### 1. Widget Priority System
```go
type WidgetPriority int

const (
    PriorityCritical WidgetPriority = iota  // Must load first (clock, weather)
    PriorityHigh                             // Important (calendar, todos)
    PriorityNormal                           // Standard widgets
    PriorityLow                              // Can load last (news feeds)
    PriorityBackground                       // Update in background
)
```

### 2. Async Widget Interface
```go
type AsyncWidget interface {
    Widget
    GetPriority() WidgetPriority
    LoadAsync(ctx context.Context) <-chan WidgetResult
    SupportsPartialUpdate() bool
    GetCacheStrategy() CacheStrategy
}

type WidgetResult struct {
    HTML     template.HTML
    Error    error
    Partial  bool
    CacheKey string
}
```

### 3. Widget Scheduler
```go
type WidgetScheduler struct {
    criticalQueue  chan AsyncWidget
    highQueue      chan AsyncWidget
    normalQueue    chan AsyncWidget
    lowQueue       chan AsyncWidget
    
    workers        int
    maxConcurrent  int
    timeoutPolicy  TimeoutPolicy
}
```

### 4. Progressive Rendering Pipeline
```
Client Request → 
    → Immediate: Return page skeleton with placeholders
    → Async: Start widget loading by priority
    → Stream: Send widget HTML via WebSocket/SSE as ready
    → Update: Client-side DOM updates without refresh
```

### 5. Connection Pool Manager
```go
type ConnectionPoolManager struct {
    pools map[string]*ConnectionPool
    
    maxConnsPerHost    int
    maxIdleConns       int
    idleTimeout        time.Duration
    http2Enabled       bool
}
```

## Implementation Phases

### Phase 1: Core Infrastructure (Week 1-2)
- Widget priority queue system
- Async widget interface
- Context propagation with cancellation
- Connection pool manager

### Phase 2: Progressive Rendering (Week 3-4)
- WebSocket/SSE endpoint for updates
- Client-side update manager (JavaScript)
- Skeleton screen templates
- Partial update protocol

### Phase 3: Widget Migration (Week 5-6)
- Convert widgets to async pattern
- Add retry logic with exponential backoff
- Implement circuit breakers for external APIs
- Add request deduplication

### Phase 4: Performance Optimization (Week 7)
- HTTP/2 multiplexing
- Request batching for similar APIs
- Intelligent prefetching
- Edge caching strategies

### Phase 5: Monitoring & Rollout (Week 8)
- OpenTelemetry integration
- Performance metrics dashboard
- Feature flags for gradual rollout
- A/B testing framework

## Performance Targets

| Metric | Current | Target | Improvement |
|--------|---------|--------|-------------|
| First Contentful Paint | ~2-3s | <500ms | 80% faster |
| Time to Interactive | ~5-10s | <2s | 75% faster |
| Total Load Time | ~10-15s | <3s | 70% faster |
| Failed Widget Impact | Page blocks | Graceful degradation | 100% improvement |

## Migration Strategy

1. **Feature Flag System**: Enable new architecture per-user
2. **Gradual Widget Migration**: Start with low-priority widgets
3. **Backward Compatibility**: Support both old and new patterns
4. **Rollback Plan**: Quick revert via feature flags
5. **Performance Monitoring**: Track metrics during rollout

## Risk Mitigation

- **Complexity**: Modular design, extensive testing
- **Breaking Changes**: Feature flags, versioned APIs
- **Performance Regression**: Continuous benchmarking
- **Browser Compatibility**: Progressive enhancement
